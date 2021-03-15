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

fn (f File) pretty_size() string {
	sizes := ['bytes', 'KB', 'MB', 'GB', 'TB']
	size_in_bytes := f.size

	if size_in_bytes == 0 {
		return 'n/a'
	}

	index := int(math.floor(math.log(size_in_bytes) / math.log(1024)))

	if index == 0 {
		return '${size_in_bytes} ${sizes[index]}'
	}

	size_in := math.round_sig(size_in_bytes / (math.pow(1024, index)), 2)

	return '${size_in} ${sizes[index]}'
}

fn calculate_lines_of_code(source string) (int, int) {
	lines := source.split_into_lines()
	loc := lines.len
	sloc := lines.filter(it.trim_space() != '').len

	return loc, sloc
}

fn (mut app App) add_file(file File) {
	sql app.db {
		insert file into File
	}
}

fn (mut app App) find_repository_items(repo_id int, branch string, parent_path string) []File {
	valid_parent_path := if parent_path =