// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import time

fn (mut app App) fetch_tags(repo Repo) {
	tags_output := repo.git('tag --format="%(refname:lstrip=2)${log_field_separator}%(objectname)${log_field_separator}%(subject)${log_field_separator}%(authoremail)${log_field_separator}%(creatordate:rfc)"')

	for tag_output in tags_output.split_into_lines() {
		tag_parts := tag_output.split(log_field_separator)
		tag_name := tag_parts[0]
		commit_hash := tag_parts[1]
		commit_message := tag_parts[2]
		