#' Checkout Git repositories
#'
#' Checkout the `HEAD` of the current Git repository.
#'
#' @param repos Path to a Git repository
#'
#' @return Called for its side effect. Returns `repos` invisibly.
#' @export
checkout <- function(repo) {
  gert::git_open(repo)

  tryCatch(
    gert::git_branch_checkout("main", repo = repo),
    error = function(e) gert::git_branch_checkout("master", repo = repo)
  )

  invisible(repo)
}
