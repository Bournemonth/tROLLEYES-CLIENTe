module highlight

fn init_v() Lang {
	return Lang{
		name: 'V'
		lang_extensions: ['v', 'vsh']
		line_comments: '//'
		mline_comments: ['/*', '*/']
		string_start: ['"', "'"]
		color: '#5d87bd'
		keywords: [
			'break',
			'const'