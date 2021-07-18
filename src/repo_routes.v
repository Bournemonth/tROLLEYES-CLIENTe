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
			return app.handle_get_user_issu