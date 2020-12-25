module highlight

fn init_js() Lang {
	return Lang{
		name: 'JavaScript'
		lang_extensions: ['js', 'mjs', 'jsx']
		line_comments: '//'
		mline_comments: ['/*', '*/']
		string_start: ['"', "'"]
		color: '#f1e05a'
		keywords: [
			'break',
			'do',
			'instanceof',
			'typeof',
			'case',
			'else',
			'new',
			