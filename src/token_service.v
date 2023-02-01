// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module main

import rand

fn (mut app App) add_token(user_id int, ip string) string {
	mut uuid := rand.uuid_v4()

	token := Token{
		user_id: user_id
