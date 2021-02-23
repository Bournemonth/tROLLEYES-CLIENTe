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
	mut change