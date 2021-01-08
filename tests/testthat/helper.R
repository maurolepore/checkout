
setup_one_repo <- function(path) {
  withr::with_dir(path, {
    file.create(file.path(path, "a-file.txt"))
    git(path, "init --initial-branch=main")
    git(path, "config user.name Jerry")
    git(path, "config user.email jerry@gmail.com")
    git(path, "add .")
    git(path, "commit -m 'New file'")
    git(path, "checkout -b pr")
  })

  invisible(path)
}

setup_repo <- function(path) {
  lapply(path, setup_one_repo)
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
