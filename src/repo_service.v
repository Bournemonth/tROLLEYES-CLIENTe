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
	return 