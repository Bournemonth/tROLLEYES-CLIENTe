
import os
import net.http
import time
import json
import api

const gitly_url = 'http://127.0.0.1:8080'

const default_branch = 'main'

const test_username = 'bob'

const test_github_repo_url = 'https://github.com/vlang/pcre'

const test_github_repo_primary_branch = 'master'

fn main() {
	before()!

	test_index_page()

	ilog('Register the first user `${test_username}`')
	mut register_headers, token := register_user(test_username, '1234zxcv', 'bob@example.com') or {
		exit_with_message(err.str())
	}

	ilog('Check all cookies that must be present')
	assert register_headers.contains(.set_cookie)

	ilog('Ensure the login token is present after registration')
	has_token := token != ''
	assert has_token

	test_user_page(test_username)
	test_login_with_token(test_username, token)
	test_static_served()

	test_create_repo(token, 'test1', '')
	assert get_repo_commit_count(token, test_username, 'test1', default_branch) == 0
	assert get_repo_issue_count(token, test_username, 'test1') == 0
	assert get_repo_branch_count(token, test_username, 'test1') == 0

	test_create_repo(token, 'test2', test_github_repo_url)
	assert get_repo_commit_count(token, test_username, 'test2', test_github_repo_primary_branch) > 0
	assert get_repo_issue_count(token, test_username, 'test2') == 0
	assert get_repo_branch_count(token, test_username, 'test2') > 0

	after()!
}

fn before() ! {
	cd_executable_dir()!

	ilog('Make sure gitly is not running')
	kill_gitly_processes()

	remove_database_if_exists()!
	remove_repos_dir_if_exists()!
	compile_gitly()

	ilog('Start gitly in the background, then wait till gitly starts and is responding to requests')
	spawn run_gitly()

	wait_gitly()
}

fn after() ! {
	remove_database_if_exists()!
	remove_repos_dir_if_exists()!

	ilog('Ensure gitly is stopped')
	kill_gitly_processes()
}

fn run_gitly() {
	gitly_process := os.execute('./gitly &')
	if gitly_process.exit_code != 0 {
		exit_with_message(gitly_process.str())
	}
}

[noreturn]
fn exit_with_message(message string) {
	println(message)
	exit(1)
}

fn ilog(message string) {
	println('${time.now().format_ss_milli()} | ${message}')
}

fn cd_executable_dir() ! {
	executable_dir := os.dir(os.executable())
	// Ensure that we are always running in the gitly folder, no matter what is the starting one:
	os.chdir(os.dir(executable_dir))!

	ilog('Testing first gitly run.')
}

fn kill_gitly_processes() {
	os.execute('pkill -9 gitly')
}

fn remove_database_if_exists() ! {