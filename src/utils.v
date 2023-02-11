module main

import time
import math
import os

pub fn (mut app App) running_since() string {
	duration := time.now().unix - app.started_at

	seconds_in_hour := 60 * 60

	day