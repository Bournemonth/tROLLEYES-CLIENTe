
module main

import crypto.sha256
import time
import os

pub fn (mut app App) set_user_block_status(user_id int, status bool) {
	sql app.db {
		update User set is_blocked = status where id == user_id
	}
}

pub fn (mut app App) set_user_admin_status(user_id int, status bool) {
	sql app.db {
		update User set is_admin = status where id == user_id
	}
}

fn hash_password_with_salt(password string, salt string) string {
	salted_password := '${password}${salt}'

	return sha256.sum(salted_password.bytes()).hex().str()
}

fn compare_password_with_hash(password string, salt string, hashed string) bool {
	return hash_password_with_salt(password, salt) == hashed
}

pub fn (mut app App) register_user(username string, password string, salt string, emails []string, github bool, is_admin bool) bool {
	mut user := app.get_user_by_username(username) or { User{} }

	if user.id != 0 && user.is_registered {
		app.info('User ${username} already exists')
		return false
	}

	user = app.get_user_by_email(emails[0]) or { User{} }

	if user.id == 0 {
		user = User{
			username: username
			password: password
			salt: salt
			created_at: time.now()
			is_registered: true
			is_github: github
			github_username: username
			avatar: default_avatar_name
			is_admin: is_admin
		}

		app.add_user(user)

		mut u := app.get_user_by_username(user.username) or {
			app.info('User was not inserted')
			return false
		}

		if u.password != user.password || u.username != user.username {
			app.info('User was not inserted')
			return false
		}

		app.add_activity(u.id, 'joined')

		for email in emails {
			app.add_email(u.id, email)
		}

		u.emails = app.find_user_emails(u.id)
	} else {
		// Update existing user
		if !github {
			app.create_user_dir(username)

			return true
		}

		if user.is_registered {
			sql app.db {
				update User set is_github = true where id == user.id
			}
			return true
		}
	}
	app.create_user_dir(username)

	return true
}

fn (mut app App) create_user_dir(username string) {
	user_path := '${app.config.repo_storage_path}/${username}'

	os.mkdir(user_path) or {
		app.info('Failed to create ${user_path}')
		app.info('Error: ${err}')
		return
	}
}

pub fn (mut app App) update_user_avatar(user_id int, filename_or_url string) {