
module main

import time

struct Repo {
	id                 int       [primary; sql: serial]
	git_dir            string
	name               string
	user_id            int
	user_name          string
	clone_url          string    [skip]
	primary_branch     string
	description        string
	is_public          bool
	users_contributed  []string  [skip]
	users_authorized   []string  [skip]
	topics_count       int       [skip]
	views_count        int
	latest_update_hash string    [skip]
	latest_activity    time.Time [skip]
mut: