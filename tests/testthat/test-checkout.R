library(gert)
library(withr)

test_that("from the working directory, checkouts the HEAD", {
  repo <- local_tempdir()
  local_dir(repo)
  git_init(repo)

  file.create("a")
  git_add("a")

  id <- git_commit("New file")
  checkout(repo)
  expect_equal(git_commit_id(ref = "HEAD", repo = repo), id)
})

test_that("from outside the working directory, checkouts the main branch", {
  repo <- local_tempdir()
  git_init(repo)

  file.create(file.path(repo, "a"))
  git_add("a", repo = repo)

  id <- git_commit("New file", repo = repo)
  checkout(repo)
  expect_equal(git_commit_id(ref = "HEAD", repo = repo), id)
})
