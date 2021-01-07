walk_git <- function(path, command, stop_on_error = TRUE, ...) {
  map_git(path = path, command = command, stop_on_error = stop_on_error, ...)
  invisible(path)
}

map_git <- function(path, command, stop_on_error = TRUE, ...) {
  out <- lapply(
    path,
    function(x) {
      git_imp(path = x, command = command, stop_on_error = stop_on_error, ...)
    }
  )

  out <- stats::setNames(out, path)
  out
}

git_imp <- function(path, command, stop_on_error = TRUE, ...) {
  out <- system(
    git_command(path, command),
    intern = TRUE, ...
  )

  if (stop_on_error && is_git_error(out)) {
    stop(out[[1]], call. = FALSE)
  }

  out
}

git_command <- function(path, command) {
  sprintf("git -C %s %s 2>&1", path, command)
}

is_git_error <- function(out) {
  status <- attributes(out)$status
  !is.null(status) && status > 0L
}
