module main

import vweb
import api

['/api/v1/:user/:repo_name/branches/count']
fn (mut app App) handle_branch_count(username string, repo_name string) vweb.Result {
	has_access := app.has_user_repo_read_access_by_repo_name(app.user.id, username, repo_nam