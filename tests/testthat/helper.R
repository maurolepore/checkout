
setup_one_repo <- function(path) {
  oldwd <- getwd()
  setwd(path)
  on.exit(setwd(oldwd), add = TRUE)

  file.create(file.path(path, "a-file.txt"))
  system("git init --initial-branch=main", intern = TRUE)
  system("git config user.name Jerry")
  system("git config user.email jerry@gmail.com")
  system("git add .")
  system("git commit -m 'New file'", intern = TRUE)
  system("git checkout -b pr")
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
