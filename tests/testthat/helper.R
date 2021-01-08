
setup_one_repo <- function(path) {
  withr::with_dir(path, {
    a_file <- file.path(path, "a-file.txt")
    file.create(a_file)
    writeLines("Some text", a_file)

    system("git init --initial-branch=main", intern = TRUE)
    system("git init --initial-branch=main", intern = TRUE)
    system("git config user.name Jerry", intern = TRUE)
    system("git config user.email jerry@gmail.com", intern = TRUE)
    system("git add .", intern = TRUE)
    system("git commit -m 'New file'", intern = TRUE)
    system("git checkout -b pr", intern = TRUE)
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
