#' Checkout Git repositories
#'
#' Checkout the `main` or `master` branch of the given Git repositories. But
#' stay on the current reference (e.g. branch) if checking out the repository
#' that called `checkout()`.
#'
#' @param repos Path to one or more Git repositories.
#'
#' @return Called for its side effect. Returns `repos` invisibly.
#' @export
#' @examples
#' library(magrittr)
#'
#' # Helper
#' walk <- function(x, f, ...) {
#'   lapply(x, f, ...)
#'   invisible(x)
#' }
#'
#' # Setup two minimal repositories.
#' repos <- file.path(tempdir(), paste0("repo", 1:2))
#' repos
#' repos %>% walk(dir.create)
#' repos %>%
#'   file.path("a-file.txt") %>%
#'   walk(file.create)
#' repos %>%
#'   git("init --initial-branch=main") %>%
#'   git("config user.name Jerry") %>%
#'   git("config user.email jerry@gmail.com") %>%
#'   git("add .") %>%
#'   git("commit -m 'New file'")
#'
#' # If we set the directory at `repo1`, it stays at the branch `pr`, whereas the
#' # `repo2` changes to the branch `master` (or `main`).
#'
#' oldwd <- getwd()
#' setwd(repos[[1]])
#'
#' repos %>% git("checkout -b pr")
#'
#' # Compare before and after `checkout()`
#' repos %>% git("branch", verbose = TRUE)
#' repos %>% checkout()
#' repos %>% git("branch", verbose = TRUE)
#'
#' # Cleanup
#' setwd(oldwd)
#' repos %>% walk(unlink, recursive = TRUE)
checkout <- function(repos) {
  unlist(lapply(repos, checkout_repo))
  invisible(repos)
}

checkout_repo <- function(repo) {
  stop_wip(repo)

  if (file_path(repo) == file_path(getwd())) {
    return(invisible(repo))
  } else {
    checkout_default_branch(repo)
  }

  invisible(repo)
}

stop_wip <- function(repo) {
  if (has_uncommited_changes(repo)) {
    stop("`repo` must not have uncommited changes: ", repo, call. = FALSE)
  }

  invisible(repo)
}

has_uncommited_changes <- function(repo) {
  status <- git_chr(repo, "status")
  clean <- any(grepl("nothing to commit", status))
  !clean
}

file_path <- function(path) {
  remake_path <- function(x) file.path(dirname(x), basename(x))
  unlist(lapply(path, remake_path))
}

checkout_default_branch <- function(repo) {
  branches <- system(git_command(repo, "branch"), intern = TRUE)
  checkout_default <- sprintf("checkout %s", get_default_branch(branches))
  git(repo, checkout_default)

  invisible(repo)
}

get_default_branch <- function(x) {
  choices <- "^[*] main$|^[ ] main$|^[*] master$|^[ ] master$"

  out <- grep(choices, x, value = TRUE)
  out <- gsub("[* ]", "", out)
  out
}
