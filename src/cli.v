// Copyright (c) 2020-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import os

pub fn (mut app App) command_fetcher() {
	for {
		line := os.get_line()

		if line.starts_with('!') {
			args := line[1..].split(' ')

			if args.len > 0 {
				match args[0] {
					'adduser' {
						if args.len > 4 {
							app.registe