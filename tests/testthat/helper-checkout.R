initialize_repo_with_new_file <- function(path) {
  if (dir.exists(path)) unlink(path, recursive = TRUE)
  dir.create(path)

  path <- git_init(path)

  file.create(file.path(path, "a"))
  git_add(".", repo = path)
  git_commit("New file", repo = path)

  invisible(path)
}

temp_repo <- function() {
  file.path(tempdir(), "repo")
}
