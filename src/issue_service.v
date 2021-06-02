
// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import time

fn (mut app App) add_issue(repo_id int, author_id int, title string, text string) {
	issue := Issue{
		title: title
		text: text
		repo_id: repo_id
		author_id: author_id
		created_at: int(time.now().unix)
	}

	sql app.db {
		insert issue into Issue
	}
}

fn (mut app App) find_issue_by_id(issue_id int) ?Issue {
	issue := sql app.db {
		select from Issue where id == issue_id limit 1
	}
	if issue.id == 0 {
		return none
	}
	return issue
}

fn (mut app App) find_repo_issues_as_page(repo_id int, page int) []Issue {
	off := page * commits_per_page
	return sql app.db {
		select from Issue where repo_id == repo_id && is_pr == false limit 35 offset off
	}