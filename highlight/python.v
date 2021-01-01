module highlight

fn init_py() Lang {
	return Lang{
		name: 'Python'
		lang_extensions: ['py', 'ipynb']
		line_comments: '#'
		string_start: ['"', "'", '"""', "'''"]
		color: '#3572A5'
		keywords: [
			'None',
			'True',
			'and',
			'as',
			'assert',
			'async',
			'await',
			'break'