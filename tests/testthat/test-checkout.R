library(gert)
library(withr)

initialize_repo_with_new_file <- function(path) {
  repo <- git_init(path)
  git_config_set("user.name", "Jerry", repo = repo)
  git_config_set("user.email", "jerry@gmail.com", repo = repo)

  file.create(file.path(repo, "a"))
  git_add(".", repo = repo)
  git_commit("New file", repo = repo)

  invisible(path)
}

test_that("with a non-repo errors gracefully", {
  non_repo <- local_tempdir()
  expect_error(checkout(non_repo), "not.*repo")
})

test_that("from inside the working directory, checkouts the current branch", {
  repo <- initialize_repo_with_new_file(tempdir())

  oldwd <- getwd()
  setwd(repo)
  on.exit(setwd(oldwd), add = TRUE)

  git_branch_create("pr", checkout = TRUE, repo = repo)

  checkout(repo)
  expect_equal(git_branch(repo = repo), "pr")

  setwd(oldwd)
})

test_that("checkouts the master branch of multiple repos", {
  repo1 <- initialize_repo_with_new_file(local_tempdir())
  git_branch_create("pr", checkout = TRUE, repo = repo1)
  repo2 <- initialize_repo_with_new_file(local_tempdir())
  git_branch_create("pr", checkout = TRUE, repo = repo2)

  checkout(c(repo1, repo2))
  expect_equal(git_branch(repo = repo1), "master")
  expect_equal(git_branch(repo = repo2), "master")
})

test_that("checkouts the master branch of a repo and the current branch of
          the current working directory", {
  repo <- initialize_repo_with_new_file(file.path(tempdir(), "repo"))
  git_branch_create("pr", checkout = TRUE, repo = repo)

  wd <- initialize_repo_with_new_file(file.path(tempdir(), "wd"))

  oldwd <- getwd()
  setwd(wd)
  on.exit(setwd(oldwd), add = TRUE)

  git_branch_create("pr", checkout = TRUE, repo = wd)

  checkout(c(repo, wd))
  expect_equal(git_branch(repo = repo), "master")
  expect_equal(git_branch(repo = wd), "pr")

  setwd(oldwd)
})

test_that("from outside the working directory, checkouts the master branch", {
  repo <- initialize_repo_with_new_file(local_tempdir())
  git_branch_create("pr", checkout = TRUE, repo = repo)

  checkout(repo)
  expect_equal(git_branch(repo = repo), "master")
})

test_that("works with the 'main' branch of a repo and prefers it over master", {
  repo <- initialize_repo_with_new_file(local_tempdir())
  git_branch_create("main", checkout = TRUE, repo = repo)

  checkout(repo)
  expect_equal(git_branch(repo = repo), "main")
})

test_that("with uncommited changes throws an error", {
  repo <- initialize_repo_with_new_file(local_tempdir())
  writeLines("change but don't commit", file.path(repo, "a"))
  expect_error(checkout(repo), "uncommited changes")
})

test_that("returns repos invisibly", {
  repo <- initialize_repo_with_new_file(local_tempdir())
  expect_invisible(checkout(repo))
})
