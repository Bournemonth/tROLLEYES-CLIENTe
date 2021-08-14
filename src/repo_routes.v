module main

import vweb
import crypto.sha1
import os
import highlight
import time
import validation
import git

['/:username/repos']
pub fn (mut app App) user_repos(username string) vweb.Result {
	exists, user := app.check_username(username)

	if !exists {
		return app.not_found()
	}

	mut repos := app.find_user_public_repos(user.id)

	if user.id == app.user.id {
		repos = app.find_user_repos(user.id)
	}

	return $vweb.html()
}

['/:username/stars']
pub fn (mut app App) user_stars(username string) vweb.Result {
	exists, user := app.check_username(username)

	if !exists {
		return app.not_found()
	}

	repos := app.find_user_starred_repos(app.user.id)

	return $vweb.html()
}

['/:username/:repo_name/settings']
pub fn (mut app App) repo_settings(username string, repo_name string) vweb.Result {
	repo := app.find_repo_by_name_and_username(repo_name, username)
	is_owner := app.check_repo_owner(app.user.username, repo_name)

	if !is_owner {
		return app.redirect_to_repository(username, repo_name)
	}

	return $vweb.html()
}

['/:username/:repo_name/settings'; post]
pub fn (mut app App) handle_update_repo_settings(username string, repo_name string, webhook_secret string) vweb.Result {
	repo := app.find_repo_by_name_and_username(repo_name, username)
	is_owner := app.check_repo_owner(app.user.username, repo_name)

	if !is_owner {
		return app.redirect_to_repository(username, repo_name)
	}

	if webhook_secret != '' && webhook_secret != repo.webhook_secret {
		webhook := sha1.hexhash(webhook_secret)
		app.set_repo_webhook_secret(repo.id, webhook)
	}

	return app.redirect_to_repository(username, repo_name)
}

['/:user/:repo_name/delete'; post]
pub fn (mut app App) handle_repo_delete(username string, repo_name string) vweb.Result {
	repo := app.find_repo_by_name_and_username(repo_name, username)
	is_owner := app.check_repo_owner(app.user.username, repo_name)

	if !is_owner {
		return app.redirect_to_repository(username, repo_name)
	}

	if app.form['verify'] == '${username}/${repo_name}' {
		spawn app.delete_repository(repo.id, repo.git_dir, repo.name)
	} else {
		app.error('Verification failed')
		return app.repo_settings(username, repo_name)
	}

	return app.redirect_to_index()
}

['/:username/:repo_name/move'; post]
pub fn (mut app App) handle_repo_move(username string, repo_name string, dest string, verify string) vweb.Result {
	repo := app.find_repo_by_name_and_username(repo_name, username)
	is_owner := app.check_repo_owner(app.user.username, repo_name)

	if !is_owner {
		return app.redirect_to_repository(username, repo_name)
	}

	if dest != '' && verify == '${username}/${repo_name}' {
		dest_user := app.get_user_by_username(dest) or {
			app.error('Unknown user ${dest}')
			return app.repo_settings(username, repo_name)
		}

		if app.user_has_repo(dest_user.id, repo.name) {
			app.error('User already owns repo ${repo.name}')
			return app.repo_settings(username, repo_name)
		}

		if app.get_count_user_repos(dest_user.id) >= max_user_repos {
			app.error('User already reached the repo limit')
			return app.repo_settings(username, repo_name)
		}

		app.move_repo_to_user(repo.id, dest_user.id, dest_user.username)

		return app.redirect('/${dest_user.username}/${repo.name}')
	} else {
		app.error('Verification failed')

		return app.repo_settings(username, repo_name)
	}

	return app.redirect_to_index()
}

['/:username/:repo_name']
pub fn (mut app App) handle_tree(username string, repo_name string) vweb.Result {
	match repo_name {
		'repos' {
			return app.user_repos(username)
		}
		'issues' {
			return app.handle_get_user_issues(username)
		}
		'settings' {
			return app.user_settings(username)
		}
		else {}
	}

	repo := app.find_repo_by_name_and_username(repo_name, username)

	if repo.id == 0 {
		return app.not_found()
	}

	return app.tree(username, repo_name, repo.primary_branch, '')
}

['/:username/:repo_name/tree/:branch_name']
pub fn (mut app App) handle_branch_tree(username string, repo_name string, branch_name string) vweb.Result {
	repo := app.find_repo_by_name_and_username(repo_name, username)

	if repo.id == 0 {
		return app.not_found()
	}

	return app.tree(username, repo_name, branch_name, '')
}

['/:username/:repo_name/update']
pub fn (mut app App) handle_repo_update(username string, repo_name string) vweb.Result {
	mut repo := app.find_repo_by_name_and_username(repo_name, username)

	if repo.id == 0 {
		return app.not_found()
	}

	if app.user.is_admin {
		app.update_repo_from_remote(mut repo)
		app.slow_fetch_files_info(mut repo, 'master', '.')
	}

	return app.redirect_to_repository(username, repo_name)
}

['/new']
pub fn (mut app App) new() vweb.Result {
	if !app.logged_in {
		return app.redirect_to_login()
	}

	return $vweb.html()
}

['/new'; post]
pub fn (mut app App) handle_new_repo(name string, clone_url string, description string, no_redirect string) vweb.Result {
	mut valid_clone_url := clone_url
	is_clone_url_empty := validation.is_string_empty(clone_url)
	is_public := app.form['repo_visibility'] == 'public'

	if !app.logged_in {
		return app.redirect_to_login()
	}

	if app.get_count_user_repos(app.user.id) >= max_user_repos {
		app.error('You have reached the limit for the number of repositories')

		return app.new()
	}

	if name.len > max_repo_name_len {
		app.error('The repository name is too long (should be fewer than ${max_repo_name_len} characters)')
		return app.new()
	}

	repo := app.find_repo_by_name_and_username(name, app.user.username)

	if repo.id != 0 {
		app.error('A repository with the name "${name}" already exists')
		return app.new()
	}

	if name.contains(' ') {
		app.error('Repository name cannot contain spaces')
		return app.new()
	}

	is_repo_name_valid := validation.is_repository_name_valid(name)

	if !is_repo_name_valid {
		app.error('The repository name is not valid')

		return app.new()
	}

	has_clone_url_https_prefix := clone_url.starts_with('https://')

	if !is_clone_url_empty {
		if !has_clone_url_https_prefix {
			valid_clone_url = 'https://' + clone_url
		}

		is_git_repo := git.check_git_repo_url(valid_clone_url)

		if !is_git_repo {
			app.error('The repository URL does not contain any git repository or the server does not respond')

