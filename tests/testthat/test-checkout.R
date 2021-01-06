library(gert)
library(withr)

test_that("with a non-repo errors gracefully", {
  non_repo <- temp_dir()
  on.exit(unlink(non_repo, recursive = TRUE))

  expect_error(checkout(non_repo), "not.*repo")
})

test_that("from inside the working directory, checkouts the current branch", {
  path <- initialize_repo_with_new_file(temp_dir())
  on.exit(unlink(path, recursive = TRUE))

  git_branch_create("pr", repo = path)
  git_branch_checkout("pr", repo = path)

  oldwd <- getwd()
  setwd(path)
  on.exit(setwd(oldwd), add = TRUE)
  getwd()
  checkout(path)
  expect_equal(git_branch(repo = path), "pr")

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
  path <- initialize_repo_with_new_file(file.path(tempdir(), "repo"))
  git_branch_create("pr", checkout = TRUE, repo = path)

  wd <- initialize_repo_with_new_file(file.path(tempdir(), "wd"))

  oldwd <- getwd()
  setwd(wd)
  on.exit(setwd(oldwd), add = TRUE)

  git_branch_create("pr", checkout = TRUE, repo = wd)

  checkout(c(path, wd))
  expect_equal(git_branch(repo = path), "master")
  expect_equal(git_branch(repo = wd), "pr")

  setwd(oldwd)
})

test_that("from outside the working directory, checkouts the master branch", {
  path <- initialize_repo_with_new_file(local_tempdir())
  git_branch_create("pr", checkout = TRUE, repo = path)

  checkout(path)
  expect_equal(git_branch(repo = path), "master")
})

test_that("works with the 'main' branch of a repo and prefers it over master", {
  path <- initialize_repo_with_new_file(local_tempdir())
  git_branch_create("main", checkout = TRUE, repo = path)

  checkout(path)
  expect_equal(git_branch(repo = path), "main")
})

test_that("with uncommited changes throws an error", {
  path <- initialize_repo_with_new_file(local_tempdir())
  writeLines("change but don't commit", file.path(path, "a"))
  expect_error(checkout(path), "uncommited changes")
})

test_that("returns repos invisibly", {
  path <- initialize_repo_with_new_file(local_tempdir())
  expect_invisible(checkout(path))
})

