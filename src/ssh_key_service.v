module main

import time

fn (mut app App) add_ssh_key(user_id int, title string, key string) ? {
	ssh_key := sql app.db {
		select from SshKey where user_id == user_id && title == title limit 1
	}

	if ssh_key.id != 0 {
		return error('SSH Key already exists')
	}

	new_ssh_key 