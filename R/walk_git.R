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
#' @return `walk_git()` is called for its side effect; it returns `path`
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
#'   walk_git("status") %>%
#'   try()
#'
#' # Don't throw an error
#' repos %>%
#'   walk_git("status", stop_on_error = FALSE)
#'
#' repos %>% walk_git("init")
#'
#' repos %>% walk_git("status")
#' repos %>% walk_git("status", verbose = TRUE)
#'
#' repos %>%
#'   walk_git("add .") %>%
#'   walk_git("config user.name Jerry") %>%
#'   walk_git("config user.email jerry@gmail.com") %>%
#'   walk_git("commit -m 'Initialize' --allow-empty") %>%
#'   walk_git("log --oneline -n 1", verbose = TRUE)
#'
#' # Cleanup
#' walk(repos, unlink, recursive = TRUE)
walk_git <- function(path, command, verbose = FALSE, stop_on_error = TRUE, ...) {
  if (verbose) {
    print(
      map_git(path = path, command = command, stop_on_error = stop_on_error, ...)
    )
  } else {
    map_git(path = path, command = command, stop_on_error = stop_on_error, ...)
  }

  invisible(path)
}

map_git <- function(path, command, stop_on_error = TRUE, ...) {
  out <- lapply(
    path,
    function(x) {
      git_impl(path = x, command = command, stop_on_error = stop_on_error, ...)
    }
  )

  out <- stats::setNames(out, path)
  out
}

git_impl <- function(path, command, stop_on_error, ...) {
  out <- suppressWarnings(
    system(git_command(path, command), intern = TRUE, ...)
  )


  if (stop_on_error && did_throw_error(out)) {
    # FIXME?
    stop(out[[1]], call. = FALSE)
  }

  out
}

did_throw_error <- function(x) {
  status <- attributes(x)$status
  !is.null(status) && status > 0L
}

git_command <- function(path, command) {
  sprintf("git -C %s %s 2>&1", path, command)
}
