module git

// parse_git_branch_with_last_hash parses output from `git branch -a`
// returns the branch name
pub fn parse_git_branch_output(output string) string {
	output_part