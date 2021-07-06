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
	repo := app.find_repo_by_name_and_username(repo_name, 