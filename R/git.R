#' Pipe-able, vectorized, and lightweight implementation of git in R
#'
#' Apply a Git command to each `path`:
#'
#' * `git()` is pipe-able. It's called for its side effect.
#' * `git_chr()` Is not pipe-able. It's called to compute on Git's text-output.
#'
#' @param path Path to one or multiple Git repos.
#' @param command A Git command, e.g. "status" or "log --oneline -n 1".
#' @param verbose Print Git's output?
#' @param stop_on_error If Git fails, do you want an R error?
#' @param ... Other arguments passed to [system].
#'
#' @return `git()` is called for its side effect; it returns `path`
#'   invisibly. `git_chr()` returns a list of characters containing the text
#'   that Git outputs.
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
#' repo <- file.path(tempdir(), "repo")
#' dir.create(repo)
#'
#' # git() is a thin wrapper around `system("git -C <path> <command>", ...)`
#' # It's fit for pipes
#' repo %>%
#'   git("init --initial-branch=main") %>%
#'   git("branch")
#'
#' repos <- file.path(tempdir(), paste0("repo", 1:2))
#' repos %>% walk(dir.create)
#'
#' # Fails because the repo isn't initialized
#' repos %>%
#'   git("status") %>%
#'   try()
#'
#' # Don't throw an error
#' repos %>%
#'   git("status", stop_on_error = FALSE)
#'
#' repos %>% git("init")
#'
#' repos %>% git("status")
#' repos %>% git("status", verbose = TRUE)
#'
#' repos %>%
#'   git("add .") %>%
#'   git("config user.name Jerry") %>%
#'   git("config user.email jerry@gmail.com") %>%
#'   git("commit -m 'Initialize' --allow-empty") %>%
#'   git("log --oneline -n 1", verbose = TRUE)
#'
#' # Cleanup
#' walk(c(repo, repos), unlink, recursive = TRUE)
git <- function(path, command, verbose = FALSE, stop_on_error = TRUE, ...) {
  git_walk(path, command, verbose = verbose, stop_on_error = stop_on_error, ...)
}

git_walk <- function(path, command, verbose = FALSE, stop_on_error = TRUE, ...) {
  lines <- git_chr(
    path = path, command = command, stop_on_error = stop_on_error, ...
  )
  if (verbose) show(lines)

  invisible(path)
}

show <- function(x) {
  stopifnot(is.list(x))

  for (i in seq_along(x)) {
    writeLines(names(x[i]))
    lapply(x[i], writeLines)
    cat("\n")
  }

  invisible(x)
}

#' @export
#' @rdname git
git_chr <- function(path, command, stop_on_error = TRUE, ...) {
  out <- lapply(
    path,
    function(x) {
      git_impl(path = x, command = command, stop_on_error = stop_on_error, ...)
    }
  )

  out <- stats::setNames(out, path)
  out
}

git_impl <- function(path, command, stop_on_error = TRUE, ...) {
  out <- suppressWarnings(
    system(git_command(path, command), intern = TRUE, ...)
  )

  if (stop_on_error && did_throw_error(out)) {
    stop(out, call. = FALSE)
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
