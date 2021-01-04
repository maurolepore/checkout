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

test_that("with a non-repo errors gracefully", {
  non_repo <- local_tempdir()
  expect_error(checkout(non_repo), "not.*repo")
})

test_that("from inside the working directory, checkouts the current branch", {
  repo <- local_tempdir()
  local_dir(repo)

  git_init(repo)
  file.create(file.path(repo, "a"))
  git_add("a", repo = repo)
  id <- git_commit("New file", repo = repo)

  gert::git_branch_create("pr", checkout = TRUE, repo = repo)
  checkout(repo)

  expect_equal(git_branch(repo = repo), "pr")
})

test_that("checkouts the master branch of multiple repos", {
  repo1 <- local_tempdir()
  git_init(repo1)
  file.create(file.path(repo1, "a"))
  git_add("a", repo = repo1)
  id <- git_commit("New file", repo = repo1)
  gert::git_branch_create("pr", checkout = TRUE, repo = repo1)

  repo2 <- local_tempdir()
  git_init(repo2)
  file.create(file.path(repo2, "a"))
  git_add("a", repo = repo2)
  id <- git_commit("New file", repo = repo2)

  gert::git_branch_create("pr", checkout = TRUE, repo = repo2)

  checkout(c(repo1, repo2))

  expect_equal(git_branch(repo = repo1), "master")
  expect_equal(git_branch(repo = repo2), "master")
})

test_that("checkouts the master branch of a repo and the current branch of
          the current working directory", {
  repo <- local_tempdir()
  git_init(repo)
  file.create(file.path(repo, "a"))
  git_add("a", repo = repo)
  id <- git_commit("New file", repo = repo)
  gert::git_branch_create("pr", checkout = TRUE, repo = repo)

  wd <- local_tempdir()
  local_dir(wd)
  git_init(wd)
  file.create(file.path(wd, "a"))
  git_add("a", repo = wd)
  id <- git_commit("New file", repo = wd)
  gert::git_branch_create("pr", checkout = TRUE, repo = wd)

  checkout(c(repo, wd))
  expect_equal(git_branch(repo = repo), "master")
  expect_equal(git_branch(repo = wd), "pr")
})

test_that("from outside the working directory, checkouts the master branch", {
  repo <- local_tempdir()
  git_init(repo)
  file.create(file.path(repo, "a"))
  git_add("a", repo = repo)
  id <- git_commit("New file", repo = repo)

  gert::git_branch_create("pr", checkout = TRUE, repo = repo)
  checkout(repo)

  expect_equal(git_branch(repo = repo), "master")
})

test_that("works with the 'main' branch of a repo and prefers it over master", {
  repo <- local_tempdir()
  git_init(repo)
  file.create(file.path(repo, "a"))
  git_add("a", repo = repo)
  id <- git_commit("New file", repo = repo)

  gert::git_branch_create("main", checkout = TRUE, repo = repo)
  checkout(repo)

  expect_equal(git_branch(repo = repo), "main")
})
