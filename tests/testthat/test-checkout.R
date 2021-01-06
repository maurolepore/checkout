test_that("with a non-repo errors gracefully", {
  non_repo <- temp_dir()
  on.exit(destroy(non_repo), add = TRUE)

  expect_error(checkout(non_repo), "not.*repo")
})

test_that("from inside the working directory, checkouts the current branch", {
  path <- new_repo(temp_dir())
  on.exit(destroy(path), add = TRUE)

  git_branch_create("pr", repo = path)
  git_branch_checkout("pr", repo = path)

  oldwd <- getwd()
  setwd(path)
  on.exit(setwd(oldwd), add = TRUE)

  checkout(path)
  expect_equal(git_branch(repo = path), "pr")

  setwd(oldwd)
})

test_that("checkouts the master branch of multiple repos", {
  repo1 <- new_repo(temp_dir())
  on.exit(destroy(repo1), add = TRUE)
  git_branch_create("pr", checkout = TRUE, repo = repo1)

  repo2 <- new_repo(temp_dir())
  on.exit(destroy(repo2), add = TRUE)
  git_branch_create("pr", checkout = TRUE, repo = repo2)

  checkout(c(repo1, repo2))
  expect_equal(git_branch(repo = repo1), "master")
  expect_equal(git_branch(repo = repo2), "master")
})

test_that("checkouts the master branch of a repo and the current branch of
          the current working directory", {
  path <- new_repo(temp_dir("repo1"))
  git_branch_create("pr", checkout = TRUE, repo = path)

  wd <- new_repo(temp_dir("repo2"))
  git_branch_create("pr", checkout = TRUE, repo = wd)

  oldwd <- getwd()
  setwd(wd)
  on.exit(setwd(oldwd), add = TRUE)
  checkout(c(path, wd))

  expect_equal(git_branch(repo = path), "master")
  expect_equal(git_branch(repo = wd), "pr")

  setwd(oldwd)
})

test_that("from outside the working directory, checkouts the master branch", {
  path <- new_repo(temp_dir())
  git_branch_create("pr", checkout = TRUE, repo = path)

  checkout(path)
  expect_equal(git_branch(repo = path), "master")
})

test_that("works with the 'main' branch of a repo and prefers it over master", {
  path <- new_repo(temp_dir())
  on.exit(destroy(path), add = TRUE)
  git_branch_create("main", checkout = TRUE, repo = path)

  checkout(path)
  expect_equal(git_branch(repo = path), "main")
})

test_that("with uncommited changes throws an error", {
  path <- new_repo(temp_dir())
  on.exit(destroy(path), add = TRUE)
  writeLines("change but don't commit", file.path(path, "a"))
  expect_error(checkout(path), "uncommited changes")
})

test_that("returns repos invisibly", {
  path <- new_repo(temp_dir())
  on.exit(destroy(path), add = TRUE)

  expect_invisible(checkout(path))
})

