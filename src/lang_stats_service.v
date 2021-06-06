module main

import vweb

const (
	test_lang_stats = [
		LangStat{
			name: 'V'
			pct: 989
			lines_count: 96657
			color: '#5d87bd'
		},
		LangStat{
			name: 'JavaScript'
			lines_count: 1131
			color: '#f1e05a'
			pct: 11
		},
	]
)

fn (app App) add_lang_stat(lang_stat LangStat) {
