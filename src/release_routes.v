module main

import vweb
import time

const (
	releases_per_page = 20
)

['/:username/:repo_name/releases']
pub fn (mut app App) releases_default(username string, rep