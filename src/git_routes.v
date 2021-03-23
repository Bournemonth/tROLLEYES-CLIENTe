// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import vweb
import git
import compress.deflate

['/:username/:repo_name/info/refs']
fn (mut app App) handle_git_info(username string, git_repo_name string) vweb.Result {
	repo_name := git.remove_git_extension_if_exists(git_repo_name)
	user := app.get_user_by_username(username) or { return app.not_found() }
	repo := app.find_repo_by_name_and_user_id(repo_name, user.id)
	service := extract_service_from_url(app.req.url)

	if repo.id == 0 {
		return app.not_found()
	}

	if service == .unknown {
		return app.not_found()
	}

	is_receive_service := service == .receive
	is_private_repo := !repo.is_publ