module main

import vweb
import time

const (
	releases_per_page = 20
)

['/:username/:repo_name/releases']
pub fn (mut app App) releases_default(username string, repo_name string) vweb.Result {
	return app.releases(username, repo_name, 0)
}

['/:username/:repo_name/releases/:page']
pub fn (mut app App) releases(username string, repo_name string, page int) vweb.Result {
	repo := app.find_repo_by_name_and_username(repo_name, username)

	if repo.id == 0 {
		return app.not_found()
	}

	repo_id := repo.id
	mut releases := []Release{}
	mut release := Release{}

	release_count := app.get_repo_release_count(repo_id)
	offset := releases_per_page * page
	page_count := calculate_pages