#' Checkout Git repositories
#'
#' Checkout the `HEAD` of the current Git repository.
#'
#' @param repos Path to a Git repository
#'
#' @return Called for its side effect. Returns `repos` invisibly.
#' @export
checkout <- function(repos) {
  out <- lapply(repos, checkout_impl)
  unlist(out)
}

checkout_impl <- function(repo) {
  check_checkout(repo)

  if (repo == getwd()) {
    return(invisible(repo))
  } else {
    checkout_default_branch(repo)
  }

  invisible(repo)
}

check_checkout <- function(repo) {
  gert::git_open(repo)
  stopifnot(length(repo) == 1)
  has_uncommited_changes <- nrow(gert::git_status(repo = repo)) > 0L
  if (has_uncommited_changes) {
    stop("`repo` must not have uncommited changes: ", repo, call. = FALSE)
  }
}

checkout_default_branch <- function(repo) {
  tryCatch(
    gert::git_branch_checkout("main", repo = repo),
    error = function(e) gert::git_branch_checkout("master", repo = repo)
  )
}
