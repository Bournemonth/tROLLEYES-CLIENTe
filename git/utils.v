module git

import regex
import os

pub fn get_git_executable_path() ?string {
	which_result := os.execute('which git')
	which_exit_code := which_result.exit_code
	which_output := which_result.output

	if which_exit_code != 0 {
		return none
	}

	return which_output.trim(' \n')
}

pub fn