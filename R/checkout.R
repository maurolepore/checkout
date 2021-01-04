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
checkout <- function(repos) {
  unlist(lapply(repos, checkout_impl))

  invisible(repos)
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

  invisible(repo)
}

checkout_default_branch <- function(repo) {
  tryCatch(
    gert::git_branch_checkout("main", repo = repo),
    error = function(e) gert::git_branch_checkout("master", repo = repo)
  )

  invisible(repo)
}
