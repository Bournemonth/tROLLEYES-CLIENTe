// Copyright (c) 2020-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

fn (mut app App) add_security_log(log SecurityLog) {
	new_log := SecurityLog{
		...log
		kind_id: int(