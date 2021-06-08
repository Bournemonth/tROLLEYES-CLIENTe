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
	sql app.db {
		insert lang_stat into LangStat
	}
}

pub fn (l &LangStat) pct_html() vweb.RawHtml {
	x := f64(l.pct) / 10.0
	sloc := if l.lines_count < 1000 {
		l.lines_count.str()
	} else {
		(l.lines_count / 1000).str() + 'k'
	}

	return '<span>${x}%</span> <spa