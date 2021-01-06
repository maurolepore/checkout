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
#' library(checkout)
#' library(gert)
#'
#' # Setup two minimal repositories.
#' repo_a <- file.path(tempdir(), "repo_a")
#' dir.create(repo_a)
#' file.create(file.path(repo_a, "a-file.txt"))
#' git_init(repo_a)
#' git_config_set("user.name", "Jerry", repo = repo_a)
#' git_config_set("user.email", "jerry@gmail.com", repo = repo_a)
#' git_add(".", repo = repo_a)
#' git_commit_all("New file", repo = repo_a)
#'
#' repo_b <- file.path(tempdir(), "repo_b")
#' dir.create(repo_b)
#' file.create(file.path(repo_b, "a-file.txt"))
#' git_init(repo_b)
#' git_config_set("user.name", "Jerry", repo = repo_b)
#' git_config_set("user.email", "jerry@gmail.com", repo = repo_b)
#' git_add(".", repo = repo_b)
#' git_commit_all("New file", repo = repo_b)
#'
#' # If we set the directory at `repo_a`, it stays at the branch `pr`, whereas the
#' # `repo_b` changes to the branch `master` (or `main`).
#'
#' oldwd <- getwd()
#' setwd(repo_a)
#'
#' git_branch_create("pr", checkout = TRUE, repo = repo_a)
#' git_branch_create("pr", checkout = TRUE, repo = repo_b)
#'
#' # Before
#' git_branch(repo_a)
#' git_branch(repo_b)
#'
#' checkout(c(repo_a, repo_b))
#'
#' # After
#' git_branch(repo_a)
#' git_branch(repo_b)
#'
#' # Cleanup
#' unlink(repo_a)
#' unlink(repo_b)
#' setwd(oldwd)
checkout <- function(repos) {
  unlist(lapply(repos, checkout_impl))

  invisible(repos)
}

checkout_impl <- function(repo) {
  check_checkout(repo)

  repo_is_wd <- normalizePath(repo) == normalizePath(getwd())
  if (repo_is_wd) {
    return(invisible(repo))
  } else {
    checkout_default_branch(repo)
  }

  invisible(repo)
}

check_checkout <- function(repo) {
  git_open(repo)
  stopifnot(length(repo) == 1)

  has_uncommited_changes <- nrow(git_status(repo = repo)) > 0L
  if (has_uncommited_changes) {
    stop("`repo` must not have uncommited changes: ", repo, call. = FALSE)
  }

  invisible(repo)
}

checkout_default_branch <- function(repo) {
  tryCatch(
    git_branch_checkout("main", repo = repo),
    error = function(e) git_branch_checkout("master", repo = repo)
  )

  invisible(repo)
}
