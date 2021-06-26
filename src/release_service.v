module main

import time

pub fn (mut app App) add_release(tag_id int, repo_id int, date time.Time, notes string) {
	release := Release{
		tag_id: tag_id
		repo_id: repo_id
		notes: notes
		date: date
	}

	sql app.db {
		inse