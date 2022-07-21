module main

fn (mut app App) load_settings() {
	app.settings = sql app.db {
		select from Settings limit 1
	}
}

fn (mut app App) update_settings(oauth_cli