// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import time

fn (mut app App) fetch_tags(repo Repo) {
	tags_output := repo.git('tag --format="%(refname:lstrip=2)${log_field_separator}%(objectname)${log_field_separator}%(subject)${log_field_separator}%(authoremail)${log_field_separator}%(creatordate:rfc)"')

	for tag_output in tags_output.split_into_lines() {
		tag_parts := tag_output.split(log_field_separator)
		tag_name := tag_parts[0]
		commit_hash := tag_parts[1]
		commit_message := tag_parts[2]
		author_email := tag_parts[3]
		commit_date := time.parse_rfc2822(tag_parts[4]) or {
			app.info('Error: ${err}')
			return
		}

		user := app.get_user_by_email(author_email) or {
			User{
				username: author_email
			}
		}

		app.add_tag(repo.id, tag_name, commit_hash, commit_message, user.id, int(commit_date.unix))
	}
}

fn (mut app App) add_tag(repo_id int, tag_name string, commit_hash string, commit_message string, user_id int, date int) {
	tag := sql app.db {
		select from Tag where repo_id == repo_id