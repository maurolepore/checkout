
setup_one_repo <- function(path) {
  withr::with_dir(path, {
    a_file <- file.path(path, "a-file.txt")
    file.create(a_file)
    writeLines("Some text", a_file)

    system("git init --initial-branch=main", intern = TRUE)
    name <- "git config user.name"
    name_set <- paste0(name, " jerry")
    name_unset <- git_error(name)
    if (name_unset) system(name_set, intern = TRUE)
    mail <- "git config user.email"
    mail_set <- paste0(mail, " jerry@gmail.com")
    mail_unset <- git_error(name)
    if (mail_unset) system(mail_set, intern = TRUE)

    system("git add .", intern = TRUE)
    system("git commit -m 'New file'", intern = TRUE)
    system("git checkout -b pr", intern = TRUE)
  })

  invisible(path)
}

git_error <- function(command) {
  status <- attributes(system(command, intern = TRUE))$status
  is.null(status)
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
