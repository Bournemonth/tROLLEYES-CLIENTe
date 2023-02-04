
module main

import time
import os
import vweb
import rand
import validation
import api

pub fn (mut app App) login() vweb.Result {
	csrf := rand.string(30)
	app.set_cookie(name: 'csrf', value: csrf)

	if app.is_logged_in() {
		return app.not_found()
	}

	return $vweb.html()
}

['/login'; post]
pub fn (mut app App) handle_login(username string, password string) vweb.Result {
	if username == '' || password == '' {
		return app.redirect_to_login()
	}

	user := app.get_user_by_username(username) or { return app.redirect_to_login() }

	if user.is_blocked {
		return app.redirect_to_login()
	}

	if !compare_password_with_hash(password, user.salt, user.password) {
		app.increment_user_login_attempts(user.id)

		if user.login_attempts == max_login_attempts {
			app.warn('User ${user.username} got blocked')
			app.block_user(user.id)
		}

		app.error('Wrong username/password')

		return app.login()
	}

	if !user.is_registered {
		return app.redirect_to_login()
	}

	app.auth_user(user, app.ip())
	app.add_security_log(user_id: user.id, kind: .logged_in)

	return app.redirect('/${username}')
}

['/logout']
pub fn (mut app App) handle_logout() vweb.Result {
	app.set_cookie(name: 'token', value: '')

	return app.redirect_to_index()
}

['/:username']
pub fn (mut app App) user(username string) vweb.Result {
	exists, user := app.check_username(username)

	if !exists {
		return app.not_found()
	}

	is_page_owner := username == app.user.username
	repos := if is_page_owner {
		app.find_user_repos(user.id)
	} else {
		app.find_user_public_repos(user.id)
	}

	activities := app.find_activities(user.id)

	return $vweb.html()
}

['/:username/settings']
pub fn (mut app App) user_settings(username string) vweb.Result {
	is_users_settings := username == app.user.username

	if !app.logged_in || !is_users_settings {
		return app.redirect_to_index()
	}

	return $vweb.html()
}

['/:username/settings'; post]
pub fn (mut app App) handle_update_user_settings(username string) vweb.Result {
	is_users_settings := username == app.user.username

	if !app.logged_in || !is_users_settings {
		return app.redirect_to_index()