module validation

fn test_is_username_valid() {
	assert is_username_valid('gitly')
	assert is_username_valid('Gitly')
	assert is_username_valid('gitly1')
	assert is_username_valid('git.ly')
