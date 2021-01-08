
setup_one_repo <- function(path) {
  withr::with_dir(path, {
    a_file <- file.path(path, "a-file.txt")
    file.create(a_file)
    writeLines("Some text", a_file)

    system("git init --initial-branch=main", intern = TRUE)
    system("git init --initial-branch=main", intern = TRUE)

    unset <- function(command) {
      browser()
      status <- attributes(system(command, intern = TRUE))$status
      is.null(status)
    }

    name <- "git config --local global user.name"
    set_name <- paste0(name, " jerry")
    if (unset(name)) system(set_name, intern = TRUE)

    mail <- "git config user.email"
    set_main <- paste0(mail, " jerry@gmail.com")
    if (unset(name)) system(set_mail, intern = TRUE)

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
