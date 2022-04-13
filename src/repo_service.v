// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import os
import time
import git
import highlight
import validation

// log_field_separator is declared as constant in case we need to change it later
const (
	max_git_res_size    = 1000
	log_field_separator = '\x7F'
	ignored_folder      = ['thirdparty']
)

enum RepoStatus {
	done
	caching
	clone_failed
	clone_done
}

enum ArchiveFormat {
	zip
	tar
}

fn (f ArchiveFormat) str() string {
	return match f {
		.zip { 'zip' }
		.tar { 'tar' }
	}
}

fn (mut app App) save_repo(repo Repo) {
	id := repo.id
	desc := repo.description
	views_count := repo.views_count
	webhook_secret := repo.webhook_secret
	tags_count := repo.tags_count
	is_public := if repo.is_public { 1 } else { 0 }
	open_issues_count := repo.open_issues_count
	open_prs_count := repo.open_prs_count
	branches_count := repo.branches_count
	releases_count := repo.releases_count
	stars_count := repo.stars_count
	contributors_count := repo.contributors_count

	sql app.db {
		update Repo set description = desc, views_count = views_count, is_public = is_public,
		webhook_secret = webhook_secret, tags_count = tags_count, open_issues_count = open_issues_count,
		open_prs_count = open_prs_count, releases_count = releases_count, contributors_count = contributors_count,
		stars_count = stars_count, branches_count = branches_count where id == id
	}
}

fn (app App) find_repo_by_name_and_user_id(repo_name string, user_id int) Repo {
	mut repo := sql app.db {
		select from Repo where name == repo_name && user_id == user_id limit 1
	}

	if repo.id > 0 {
		repo.lang_stats = app.find_repo_lang_stats(repo.id)
	}

	return repo
}

fn (app App) find_repo_by_name_and_username(repo_name string, username string) Repo {
	user := app.get_user_by_username(username) or { return Repo{} }

	return app.find_repo_by_name_and_user_id(repo_name, user.id)
}

fn (mut app App) get_count_user_repos(user_id int) int {
	return sql app.db {
		select count from Repo where user_id == user_id
	}
}

fn (mut app App) find_user_repos(user_id int) []Repo {
	return sql app.db {
		select from Repo where user_id == user_id
	}
}

fn (mut app App) find_user_public_repos(user_id int) []Repo {
	return sql app.db {
		select from Repo where user_id == user_id && is_public == true
	}
}

fn (app App) search_public_repos(query string) []Repo {
	repo_rows, _ := app.db.exec('select id, name, user_id, description, stars_count from `Repo` where is_public is true and name like "%${query}%"')

	mut repos := []Repo{}

	for row in repo_rows {
		user_id := row.vals[2].int()
		user := app.get_user_by_id(user_id) or { User{} }

		repos << Repo{
			id: row.vals[0].int()
			name: row.vals[1]
			user_name: user.username
			description: row.vals[3]
			stars_count: row.vals[4].int()
		}
	}

	return repos
}

fn (app App) find_repo_by_id(repo_id int) Repo {
	mut repo := sql app.db {
		select from Repo where id == repo_id
	}

	if repo.id > 0 {
		repo.lang_stats = app.find_repo_lang_stats(repo.id)
	}

	return repo
}

fn (mut app App) increment_repo_views(repo_id int) {
	sql app.db {
		update Repo set views_count = views_count + 1 where id == repo_id
	}
}

fn (mut app App) increment_repo_stars(repo_id int) {
	sql app.db {
		update Repo set stars_count = stars_count + 1 where id == repo_id
	}
}

fn (mut app App) decrement_repo_stars(repo_id int) {
	sql app.db {
		update Repo set stars_count = stars_count - 1 where id == repo_id
	}
}

fn (mut app App) increment_file_views(file_id int) {
	sql app.db {
		update File set views_count = views_count + 1 where id == file_id
	}
}

fn (mut app App) set_repo_webhook_secret(repo_id int, secret string) {
	sql app.db {
		update Repo set webhook_secret = secret where id == repo_id
	}
}

fn (mut app App) increment_repo_issues(repo_id int) {
	sql app.db {
		update Repo set open_issues_count = open_issues_count + 1 where id == repo_id
	}
}

fn (mut app App) add_repo(repo Repo) {
	sql app.db {
		insert repo into Repo
	}
}

fn (mut app App) delete_repository(id int, path string, name string) {
	sql app.db {
		delete from Repo where id == id
	}
	app.info('Removed repo entry (${id}, ${name})')

	sql app.db {
		delete from Commit where repo_id == id
	}

	app.info('Removed repo commits (${id}, ${name})')
	app.delete_repo_issues(id)
	app.info('Removed repo issues (${id}, ${name})')

	app.delete_repo_branches(id)
	app.info('Removed repo branches (${id}, ${name})')

	app.delete_repo_releases(id)
	app.info('Removed repo releases (${id}, ${name})')

	app.delete_repository_files(id)
	app.info('Removed repo files (${id}, ${name})')

	app.delete_repo_folder(path)
	app.info('Removed repo folder (${id}, ${name})')
}

fn (mut app App) move_repo_to_user(repo_id int, user_id int, user_name string) {
	sql app.db {
		update Repo set user_id = user_id, user_name = user_name where id == repo_id
	}
}

fn (mut app App) user_has_repo(user_id int, repo_name string) bool {
	count := sql app.db {
		select count from Repo where user_id == user_id && name == repo_name
	}
	return count >= 0
}

fn (mut app App) update_repo_from_fs(mut repo Repo) {
	repo_id := repo.id

	app.db.exec('BEGIN TRANSACTION')

	repo.analyse_lang(app)

	app.info(repo.contributors_count.str())
	app.fetch_branches(repo)

	branches_output := repo.git('branch -a')

	for branch_output in branches_output.split_into_lines() {
		branch_name := git.parse_git_branch_output(branch_output)

		app.update_repo_branch_from_fs(mut repo, branch_name)
	}

	repo.contributors_count = app.get_count_repo_contributors(repo_id)
	repo.branches_count = app.get_count_repo_branches(repo_id)

	// TODO: TEMPORARY - UNTIL WE GET PERSISTENT RELEASE INFO
	for tag in app.get_all_repo_tags(repo_id) {
		app.add_release(tag.id, repo_id, time.unix(tag.created_at), tag.message)

		repo.releases_count++
	}

	app.save_repo(repo)
	app.db.exec('END TRANSACTION')
	app.info('Repo updated')
}

fn (mut app App) update_repo_branch_from_fs(mut repo Repo, branch_name string) {
	repo_id := repo.id
	branch := app.find_repo_branch_by_name(repo.id, branch_name)

	if branch.id == 0 {
		return
	}

	data := repo.git('--no-pager log ${branch_name} --abbrev-commit --abbrev=7 --pretty="%h${log_field_separator}