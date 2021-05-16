// Copyright (c) 2020-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import vweb
import time
import os
import log
import db.sqlite
import api
import config

const (
	commits_per_page   = 35
	http_port          = 8080
	expire_length      = 200
	posts_per_day      = 5
	max_username_len   = 40
	max_login_attempts = 5
	max_user_repos     = 10
	max_repo_name_len  = 100
	max_namechanges    = 3
	namechange_period  = time.hour * 24
)

struct App {
	vweb.Context
	started_at i64 [vweb_global]
pub mut:
	db sqlite.DB
mut:
	version       string        [vweb_global]
	logger        log.Log       [vweb_global]
	config        config.Config [vweb_global]
	settings      Settings
	current_path  string
	page_gen_time string
	is_tree       bool
	logged_in     bool
	user          User
	path_split    []string
	branch        string
}

fn C.sqlite3_config(int)

fn main() {
	C.sqlite3_config(3)

	if os.args.contains('ci_run') {
		return
	}

	vweb.run(new_app(), http_port)
}

fn new_app() &App {
	mut app := &App{
		db: sqlite.connect('gitly.sqlite') or { panic(err) }
		started_at: time.now().unix
	}

	set_rand_crypto_safe_seed()

	app.create_tables()

	create_directory_if_not_exists('logs')

	app.setup_logger()

	mut version := os.read_file('src/static/assets/version') or { 'unknown' }
	git_result := os.execute('git rev-parse --short HEAD')

	if git_result.exit_code == 0 && !git_result.output.contains('fatal') {
		version = git_result.output.trim_space()
	}

	if version != app.version {
		os.write_file('src/static/assets/version', app.version) or { panic(err) }
	}

	app.version = version

	app.handle_static('src/static', true)
	app.handle_static('avatars', false)

	app.load_settings()

	app.config = config.read_config('./config.json') or {
		panic('Config not found or has syntax errors')
	}

	create_directory_if_not_exists(app.config.repo_storage_path)
	create_directory_if_not_exists(app.config.archive_path)
	create_directory_if_not_exists(app.config.avatars_path)

	// Create the first admin user if the db is empty
	app.get_user_by_id(1) or {}

	if '-cmdapi' in os.args {
		spawn app.command_fetcher()
	}

	return app
}

fn (mut app App) setup_logger() {
	app.logger.set_level(.debug)

	app.logger.set_full_logpath('./logs/log_${time.now().ymmdd()}.log')
	app.logger.log_to_console_too()
}

pub fn (mut app App) warn(msg string) {
	app.logger.warn(msg)

	app.logger.flush()
}

pub fn (mut app App) info(msg string) {
	app.logger.info(msg)

	app.logger.flush()
}

pub fn (mut app App) debug(msg string) {
	app.logger.debug(msg)

	app.logger.flush()
}

pub fn (