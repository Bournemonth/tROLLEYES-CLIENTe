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
