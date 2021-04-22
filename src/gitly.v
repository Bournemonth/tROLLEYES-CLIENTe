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
	expire_length      = 2