module validation

fn test_is_username_valid() {
	assert is_username_valid('gitly')
	assert is_username_valid('Gitly')
	assert is_username_valid('gitly1')
	assert is_username_valid('git.ly')
	assert is_username_valid('git3.ly')
	assert is_username_valid('git3ly_')

	assert is_username_valid('_gitly') == false
	assert is_username_valid('git-ly') == false
	assert is_username_valid('1gitly') == false
	assert is_username_valid('') == false
	as