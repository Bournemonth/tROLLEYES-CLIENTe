module main

import vweb
import regex

fn replace_issue_id(re regex.RE, in_txt string, _ int, _ int) string {
	issue_id := re.get_gro