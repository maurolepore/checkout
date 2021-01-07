new_repo <- function(path) {
  path <- walk_git(path, "init")

  walk_git(path, "config user.name jerry")
  walk_git(path, "config user.email jerry@gmail.com")

  file.create(file.path(path, "a"))
  walk_git(path, "add .")
  walk_git(path, "commit -m 'New file'")

  invisible(path)
}

temp_dir <- function(name = "temp_dir") {
  path <- file.path(tempdir(), name)
  if (dir.exists(path)) destroy(path)
  dir.create(path, showWarnings = FALSE, recursive = TRUE)

  invisible(path)
}

destroy <- function(path) {
  unlink(path, recursive = TRUE)
}

expect_no_error <- function(object) {
  expect_error(object, regexp = NA)
}

walk <- function(x, f, ...) {
  lapply(x, f, ...)
  invisible(x)
}

