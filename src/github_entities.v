module main

struct OAuthRequest {
	client_id     string
	client_secret string
	code          string
	state         string
}

struct GitHubUser {
	username string [json: 'login']
	name   