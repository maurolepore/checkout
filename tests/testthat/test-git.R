test_that("git_chr with a repo with clean status, shows 'nothing to commit'", {
  repo <- setup_repo(temp_dir())
  on.exit(destroy(repo), add = TRUE)

  out <- git_chr(repo, "status")
  matches <- any(grepl("nothing to commit", out))

  expect_true(matches)
})

test_that("with a path that isn't a repo erorrs gracefully", {
  not_repo <- tempdir()
  if (!dir.exists(not_repo)) dir.create(not_repo)
  on.exit(destroy(not_repo), add = TRUE)

  expect_error(git(not_repo, "status"), "not a git repository")
})

test_that("is sensitive to stop_on_error", {
  not_repo <- tempdir()
  if (!dir.exists(not_repo)) dir.create(not_repo)
  on.exit(destroy(not_repo), add = TRUE)

  expect_no_error(git(not_repo, "status", stop_on_error = FALSE))
})

test_that("is vectorized", {
  path1 <- setup_repo(temp_dir("repo1"))
  on.exit(destroy(path1), add = TRUE)
  path2 <- setup_repo(temp_dir("repo2"))
  on.exit(destroy(path2), add = TRUE)

  paths <- c(path1, path2)
  out <- git(paths, "status")
  expect_length(out, length(paths))
})

test_that("returns invisible path", {
  repo <- setup_repo(temp_dir())
  on.exit(destroy(repo), add = TRUE)

  expect_equal(git(repo, "status"), repo)
  expect_invisible(git(repo, "status"))
})

test_that("is sensitive to verbose", {
  repo <- setup_repo(temp_dir())
  on.exit(destroy(repo))

  x <- capture.output(git(repo, "status", verbose = TRUE))
  y <- capture.output(git(repo, "status", verbose = FALSE))

  expect_false(identical(x, y))
  expect_true(length(x) > 0L)
  expect_true(length(y) == 0L)
})

test_that("git() is sensitive to verbose", {
  repo <- setup_repo(temp_dir())
  on.exit(destroy(repo))

  x <- capture.output(git(repo, "status", verbose = TRUE))
  y <- capture.output(git(repo, "status", verbose = FALSE))

  expect_false(identical(x, y))
  expect_true(length(x) > 0L)
  expect_true(length(y) == 0L)

  expect_snapshot_output(git(repo, "status", verbose = TRUE))
})
