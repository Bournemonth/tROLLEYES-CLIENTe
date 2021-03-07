module main

import time
import math
import os

fn (f File) url() string {
	file_type := if f.is_dir { 'tree' } else { 'blob' }

	if f.parent_path == '' {
		return '${file_type}/${f.branch}/${f.name}'
	}

	return '${file_type}/$