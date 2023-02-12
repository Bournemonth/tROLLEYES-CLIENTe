module main

fn (mut app App) watch_repo(repo_id int, user_id int) {
	watch := Watch{
		repo_id: repo_id
		user_id: user_id
	}

	sql app.db {
		insert watch into Watch
	}
}

fn (mut app App) get_count_repo_watchers(repo_id int) int {
	return sql app.db {
		select count from Watch where repo_id == repo_id
	}
}

fn (mut app App) find_watching_repo_ids(user_id int) []int {
	watch_list :=