initialize_repo_with_new_file <- function(path) {
  repo <- git_init(path)
  git_config_set("user.name", "Jerry", repo = repo)
  git_config_set("user.email", "jerry@gmail.com", repo = repo)

  file.create(file.path(repo, "a"))
  git_add(".", repo = repo)
  git_commit("New file", repo = repo)

  invisible(path)
}
