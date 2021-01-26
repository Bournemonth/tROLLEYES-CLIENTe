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

fn validate_avatar_content_type(content_type string) bool {
	return supported_mime_types.contains(content_type)
}

fn extract_file_extension_from_mime_type(mime_type string) ?string {
	is_valid_mime_type := validate_avatar_content_type(mime_type)

	if !is_valid_mime_type {
		return error('MIME type is not supported')
	}

	mime_parts := mime_type.split('/')

	return mime_parts[1]
}

fn validate_avatar_file_size(content string) bool {
	return content.len <= avatar_max_file_size
}

fn (app App) build_avatar_file_path(avatar_filename string) string {
	relative