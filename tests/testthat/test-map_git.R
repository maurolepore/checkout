test_that("is sensitive to argument `path`", {
  path <- new_repo(temp_dir())
  expect_no_error(
    map_git(path, "status")
  )
})

test_that("with a repo with clean status, shows 'nothing to commit'", {
  path <- new_repo(temp_dir())

  out <- map_git(path, "status")
  success <- is.null(attributes(out)$status)
  stopifnot(success)

  matches <- any(grepl("nothing to commit", out))

  expect_true(matches)
})

test_that("with a path that isn't a repo erorrs gracefully", {
  not_repo <- tempdir()
  stopifnot(dir.exists(not_repo))

  suppressWarnings(
    expect_error(map_git(not_repo, "status"), "not a git repository")
  )
})

test_that("is sensitive to stop_on_error", {
  not_repo <- tempdir()
  stopifnot(dir.exists(not_repo))

  suppressWarnings(
    expect_no_error(map_git(not_repo, "status", stop_on_error = FALSE))
  )
})

test_that("with multiple `path` maps each to the git command (is vectorized)", {
  path1 <- new_repo(temp_dir("repo1"))
  path2 <- new_repo(temp_dir("repo2"))

  expect_type(
    map_git(c(path1, path2), "status"),
    "list"
  )
})

test_that("walk_git returns invisibly `path`", {
  path <- new_repo(temp_dir())
  expect_invisible(walk_git(path, "status"))
})
