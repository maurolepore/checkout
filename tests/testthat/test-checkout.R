library(gert)
library(withr)

test_that("with the working repo leaves the repo at the HEAD", {
  repo <- local_tempdir()
  local_dir(repo)
  git_init(repo)

  file.create("a")
  git_add("a")

  id <- git_commit("New file")
  checkout(repo)
  expect_equal(git_commit_id(ref = "HEAD", repo = repo), id)
})
