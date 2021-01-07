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
#' repos %>% file.path("a-file.txt") %>% walk(file.create)
#' repos %>%
#'   walk_git("init") %>%
#'   walk_git("config user.name Jerry") %>%
#'   walk_git("config user.email jerry@gmail.com") %>%
#'   walk_git("add .") %>%
#'   walk_git("commit -m 'New file'")
#'
#' # If we set the directory at `repo1`, it stays at the branch `pr`, whereas the
#' # `repo2` changes to the branch `master` (or `main`).
#'
#' oldwd <- getwd()
#' setwd(repos[[1]])
#'
#' repos %>% walk_git("checkout -b pr")
#'
#' # Compare before and after `checkout()`
#' repos %>% walk_git("branch", verbose = TRUE)
#' repos %>% checkout()
#' repos %>% walk_git("branch", verbose = TRUE)
#'
#' # Cleanup
#' setwd(oldwd)
#' repos %>% walk(unlink, recursive = TRUE)
checkout <- function(repos) {
  unlist(lapply(repos, checkout_repo))
  invisible(repos)
}

checkout_repo <- function(repo) {
  check_checkout(repo)

  if (file_path(repo) == file_path(getwd())) {
    return(invisible(repo))
  } else {
    checkout_default_branch(repo)
  }

  invisible(repo)
}

check_checkout <- function(repo) {
  stopifnot(length(repo) == 1)


  if (is_git_error(walk_git(repo, "status"))) {
    stop("`repo` must be a git repository. Did you forget to initialize it?")
  }


  if (has_uncommited_changes(repo)) {
    stop("`repo` must not have uncommited changes: ", repo, call. = FALSE)
  }

  invisible(repo)
}

has_uncommited_changes <- function(repo) {
  status <- map_git(repo, "status")
  clean <- any(grepl("nothing to commit", status))
  !clean
}

file_path <- function(path) {
  remake_path <- function(x) file.path(dirname(x), basename(x))
  unlist(lapply(path, remake_path))
}

checkout_default_branch <- function(repo) {
  tryCatch(
    walk_git(repo, "checkout -b main"),
    error = function(e) {
      walk_git(repo, "checkout -b master")
    }
  )

  invisible(repo)
}
