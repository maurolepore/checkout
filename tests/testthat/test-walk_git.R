test_that("with a repo with clean status, shows 'nothing to commit'", {
  path <- new_repo(temp_dir("repo"))
  on.exit(destroy(path), add = TRUE)

  # Easiest way to get the output
  out <- map_git(path, "status")
  success <- is.null(attributes(out)$status)
  stopifnot(success)

  matches <- any(grepl("nothing to commit", out))

  expect_true(matches)
})

test_that("with a path that isn't a repo erorrs gracefully", {
  not_repo <- tempdir()
  if (!dir.exists(not_repo)) dir.create(not_repo)
  on.exit(destroy(not_repo), add = TRUE)
  stopifnot(dir.exists(not_repo))

  expect_error(walk_git(not_repo, "status"), "not a git repository")
})

test_that("is sensitive to stop_on_error", {
  not_repo <- tempdir()
  if (!dir.exists(not_repo)) dir.create(not_repo)
  on.exit(destroy(not_repo), add = TRUE)
  stopifnot(dir.exists(not_repo))

  expect_no_error(walk_git(not_repo, "status", stop_on_error = FALSE))
})

test_that("is vectorized", {
  path1 <- new_repo(temp_dir("repo1"))
  on.exit(destroy(path1), add = TRUE)
  path2 <- new_repo(temp_dir("repo2"))
  on.exit(destroy(path2), add = TRUE)


  paths <- c(path1, path2)
  out <- walk_git(paths, "status")
  expect_length(out, length(paths))
})

test_that("returns invisible path", {
  path <- new_repo(temp_dir())
  on.exit(destroy(path), add = TRUE)

  expect_equal(walk_git(path, "status"), path)
  expect_invisible(walk_git(path, "status"))
})

test_that("is sensitive to verbose", {
  repo <- setup_repo(temp_dir())
  on.exit(destroy(repo))

  x <- capture.output(walk_git(repo, "status", verbose = TRUE))
  y <- capture.output(walk_git(repo, "status", verbose = FALSE))

  expect_false(identical(x, y))
  expect_true(length(x) > 0L)
  expect_true(length(y) == 0L)
})
