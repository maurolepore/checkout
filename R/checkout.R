#' Checkout Git repositories
#'
#' Checkout the `HEAD` of the current Git repository.
#'
#' @param repos Path to a Git repository
#'
#' @return Called for its side effect. Returns `repos` invisibly.
#' @export
#'
#' @examples
#' library(gert)
#' library(withr)
#'
#' # Setup
#' stopifnot(user_is_configured())
#' repo <- local_tempdir()
#' local_dir(repo)
#' git_init(repo)
#' file.create("a")
#' git_add("a")
#' git_commit("New file")
#'
#' # The commit sha is the same before and after `checkout()`
#' gert::git_commit_id("HEAD", repo = repo)
#' checkout(repo)
#' gert::git_commit_id("HEAD", repo = repo)
checkout <- function(repos) {
  invisible(repos)
}
