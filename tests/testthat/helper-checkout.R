initialize_repo_with_new_file <- function(path) {
  repo <- git_init(path)

  file.create(file.path(repo, "a"))
  git_add(".", repo = repo)
  git_commit("New file", repo = repo)

  invisible(path)
}

temp_repo <- function() {
  file.path(tempdir(), "repo")
}
