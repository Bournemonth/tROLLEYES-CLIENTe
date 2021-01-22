module main

import os

const (
	default_avatar_name  = 'default_avatar.png'
	assets_path          = 'assets'
	avatar_max_file_size = 1 * 1024 * 1024 // 1 megabyte
	supported_mime_types = [
		'image/jpeg',
		'image/png',
		'image/webp',
	]
)

fn validate_avatar_content_type(content_type str