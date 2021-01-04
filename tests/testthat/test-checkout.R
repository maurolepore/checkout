library(gert)

test_that("with the working repo leaves the repo at the HEAD", {
  stopifnot(user_is_configured())
  repo <- withr::local_tempdir()
  withr::local_dir(repo)
  git_init(repo)

  file.create("a")
  gert::git_add("a")
  id <- gert::git_commit("New file")

  checkout(repo)
  expect_equal(gert::git_commit_id(ref = "HEAD", repo = repo), id)
})
