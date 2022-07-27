module main

fn (mut app App) add_star(repo_id int, user_id int) {
	star := Star{
		repo_id: repo_id
		user_id: user_id
	}

	sql app.db {
		insert star into Star
	}
}

fn (mut app App) find_user_starred_repos(user_id int) []Repo {
	stars := sql app.db {
		select from Star where user_id == user_id
	}
	mut repos := []Repo{}

	for star in stars {
		repo := app.find_repo_by_id(star.repo_id)

		if repo.id != 0 {
			repos << repo
		}
	}

	return repos
}

fn (mut app App) toggle_repo_star(repo_id int, user_id int) {
	is_starred := app.check_repo_starred(