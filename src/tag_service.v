// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import time

fn (mut app App) fetch_tags(repo Repo) {
	tags_output := repo.git('tag --format="%(refname:lstrip=2)${log_field_separator}%(objectname)${log_field_separator}%(subje