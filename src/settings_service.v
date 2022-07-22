module main

fn (mut app App) load_settings() {
	app.settings = sql app.db {
		select from Settings limit 1
	}
}

fn (mut app App) update_settings(oauth_client_id string, oauth_client_secret string) {
	old_settings := sql app.db {
		select from Settings limit 1
	}

	github_oauth_client_id := if oauth_client_id != '' {
		oauth_client_id
	} else {
		old_settings.oauth_client_id
	}

	git