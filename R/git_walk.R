#' Pipe-able, vectorized, and lightweight implementation of git in R
#'
#' Apply a Git command to each `path`.
#'
#' @param path Path to one or multiple Git repos.
#' @param command A Git command, e.g. "status" or "log --oneline -n 1".
#' @param verbose Print Git's output?
#' @param stop_on_error If Git fails, do you want an R error?
#' @param ... Other arguments passed to [system].
#'
#' @return `git_walk()` is called for its side effect; it returns `path`
#'   invisibly.
#'
#' @export
#'
#' @examples
#' library(magrittr)
#'
#' # helper
#' walk <- function(x, f, ...) {
#'   lapply(x, f, ...)
#'   invisible(x)
#' }
#'
#' repos <- file.path(tempdir(), paste0("repo", 1:2))
#' repos %>% walk(dir.create)
#'
#' # Fails because the repo isn't initialized
#' repos %>%
#'   git_walk("status") %>%
#'   try()
#'
#' # Don't throw an error
#' repos %>%
#'   git_walk("status", stop_on_error = FALSE)
#'
#' repos %>% git_walk("init")
#'
#' repos %>% git_walk("status")
#' repos %>% git_walk("status", verbose = TRUE)
#'
#' repos %>%
#'   git_walk("add .") %>%
#'   git_walk("config user.name Jerry") %>%
#'   git_walk("config user.email jerry@gmail.com") %>%
#'   git_walk("commit -m 'Initialize' --allow-empty") %>%
#'   git_walk("log --oneline -n 1", verbose = TRUE)
#'
#' # Cleanup
#' walk(repos, unlink, recursive = TRUE)
git <- function(path, command, stop_on_error = TRUE, ...) {
  out <- suppressWarnings(
    system(git_command(path, command), intern = TRUE, ...)
  )

  if (stop_on_error && did_throw_error(out)) {
    stop(out, call. = FALSE)
  }

  out
}

#' @export
#' @rdname git
git_walk <- function(path, command, verbose = FALSE, stop_on_error = TRUE, ...) {
  if (verbose) {
    print(
      git_map(path = path, command = command, stop_on_error = stop_on_error, ...)
    )
  } else {
    git_map(path = path, command = command, stop_on_error = stop_on_error, ...)
  }

  invisible(path)
}

git_map <- function(path, command, stop_on_error = TRUE, ...) {
  out <- lapply(
    path,
    function(x) {
      git(path = x, command = command, stop_on_error = stop_on_error, ...)
    }
  )

  out <- stats::setNames(out, path)
  out
}

did_throw_error <- function(x) {
  status <- attributes(x)$status
  !is.null(status) && status > 0L
}

git_command <- function(path, command) {
  sprintf("git -C %s %s 2>&1", path, command)
}
