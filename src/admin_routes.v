module main

import vweb

const (
	admin_users_per_page = 30
)

['/admin/settings']
pub fn (mut app App) admin_settings() vweb.Result {
	if !app.is_admin() {
		return app.redirect_to_index()
	}

	return $vweb.html()
}

['/admin/settings'; post]
pub fn (mut app App) handle_admin_update_settings(oauth_client_id string, oauth_client_secret string) vweb.Result {
	if !app.is_admin() {
		return app.redirect_to_index()
	}

	app.update_gitly_settings(oauth_client_id, oauth_client_secret)

	return app.redirect('/admin')
}

['/admin/users/:user'; post]
pub fn (mut app App) handle_admin_edit_user(user_id string) vweb.Result {
	if !app.is_admin() {
		return app.redirect_to_index()
	}

	clear_session := 'stop-session' in app.form
	is_blocked := 'is-blocked' in app.form
	is_admin := 'is-admin' in app.form

	app.edit_user(user_id.int(), clear_session, is_blocked, is_admin)

	return app.redirect('/admin')
}

['/admin/users']
pub fn (mut app App) admin_users_default() vweb.Result {
	