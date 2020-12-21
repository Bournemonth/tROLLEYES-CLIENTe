module highlight

fn init_go() Lang {
	return Lang{
		name: 'Go'
		lang_extensions: ['go']
		line_comments: '//'
		mline_comments: ['/*', '*/']
