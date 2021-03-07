module main

import time
import math
import os

fn (f File) url() string {
	file_type := if f.is_dir { 'tree' } else { 'blob' }

	if f.parent_path == '' {
		return '${file_type}/${f.branch}/${f.name}'
	}

	return '${file_type}/${f.branch}/${f.parent_path}/${f.name}'
}

fn (f &File) full_path() string {
	if f.parent_path == '' {
		return f.name
	}

	return f.parent_path + '/' + f.name
}

fn (f File) pretty_last_time() string {
	return time.unix(f.last_time).relative()
}

fn (f File) pretty_siz