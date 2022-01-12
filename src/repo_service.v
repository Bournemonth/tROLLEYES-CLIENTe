// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import os
import time
import git
import highlight
import validation

// log_field_separator is declared as constant in case we need to change it later
const (
	max_git_res_size    = 1000
	log_field_separator = '\x7F'
	ignored_folder      = ['thirdparty']
)

enum RepoStatus {
	done
	caching
	clone_failed
	clone_done
}

enum ArchiveFormat {
	zip
	tar
}

fn (f ArchiveFormat) str() string {
	return match f {
		.zip { 'zip' }
		.tar {