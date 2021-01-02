module highlight

fn init_ts() Lang {
	return Lang{
		name: 'TypeScript'
		lang_extensions: ['ts', 'tsx']
		line_comments: '//'
		mline_comments: ['/*', '*/']
		string_start: ['"', "'"]
		color: '#2b7489'
		keywords: [
			'any',
		