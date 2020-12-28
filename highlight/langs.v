// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by a GPL license that can be found in the LICENSE file.
module highlight

const (
	lang_path = 'langs'
)

const (
	langs = init_langs()
)

pub struct Lang {
	keywords        []string
	lang_extensions []string
	string_start    []string
pub:
	line_comments  string
	mline_comments []string
	color          string
	name           string
}

fn is_source(e