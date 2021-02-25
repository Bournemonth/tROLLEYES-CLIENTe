// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import time

fn (commit Commit) relative() string {
	return time.unix(commit.created_at).relative()
}

fn (commit Commit) get_changes(repo Repo) []Change {
	git_changes := repo.git('show ${commit.hash}')

	mut change := Change{}
	mut changes := []Change{}
	mut started := false
	for line in git_changes.split_into_lines() {
		args := line.split(' ')
		if args.len <= 0 {
			continue
		}

		match args[0] {
			'diff' {
				started = true
				if change.file.len > 0 {
					changes << change
					change = Change{}
				}
				change.file = args[2][2..]
			}
			'index' {
				continue
			}
			'---' {
				continue
			}
			'+++' {
				continue
			}
			'@@' {
				change.diff = line
			}
			else {
				if started {
					if line.bytes()[0] == `+` {
						change.additions++
					}
					if line