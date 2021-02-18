module main

import vweb
import validation

['/:username/:repo_name/comments'; post]
pub fn (mut app App) handle_add_comment(username string, repo_name string) vweb.Result {
	repo := app.find_repo_by_name_and_username(repo_name, username)

	if repo.id == 0 {
		return app.not_found()
	}

	text := app