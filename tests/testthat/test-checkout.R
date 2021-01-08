test_that("with a non-repo errors gracefully", {
  non_repo <- temp_dir()
  on.exit(destroy(non_repo), add = TRUE)

  expect_error(checkout(non_repo), "not.*repo")
})

test_that("from inside the working directory, checkouts the current branch", {
  path <- new_repo(temp_dir())
  on.exit(destroy(path), add = TRUE)

  walk_git(path, "checkout -b pr")

  oldwd <- getwd()
  setwd(path)
  on.exit(setwd(oldwd), add = TRUE)

  checkout(path)
  has_pr_branch <- any(grepl("* pr", map_git(path, "branch")))

  expect_true(has_pr_branch)
})

test_that("checkouts the master branch of multiple repos", {
  # Setup two minimal repositories.
  repos <- file.path(tempdir(), paste0("repo", 1:2))
  repos %>% walk(dir.create)
  on.exit(destroy(repos[[1]]), add = TRUE)
  on.exit(destroy(repos[[2]]), add = TRUE)

  repos %>%
    file.path("a-file.txt") %>%
    walk(file.create)
  repos %>%
    walk_git("init") %>%
    walk_git("config user.name Jerry") %>%
    walk_git("config user.email jerry@gmail.com") %>%
    walk_git("add .") %>%
    walk_git("commit -m 'New file'")

  checkout(repos)
  out <- repos %>% map_git("branch")
  at_main <- all(grepl("* main", out, fixed = TRUE))
  at_master <- all(grepl("* master", out, fixed = TRUE))

  expect_true(at_main || at_master)
})

test_that("stays at the branch of repo if it's the wd", {
  # Setup two minimal repositories.
  repos <- file.path(tempdir(), paste0("repo", 1:2))
  repos %>% walk(dir.create)
  on.exit(destroy(repos[[1]]), add = TRUE)
  on.exit(destroy(repos[[2]]), add = TRUE)

  repos %>%
    file.path("a-file.txt") %>%
    walk(file.create)
  repos %>%
    walk_git("init") %>%
    walk_git("config user.name Jerry") %>%
    walk_git("config user.email jerry@gmail.com") %>%
    walk_git("add .") %>%
    walk_git("commit -m 'New file'")

  oldwd <- getwd()
  setwd(repos[[1]])
  on.exit(setwd(oldwd), add = TRUE)

  repos %>% walk_git("checkout -b pr")
  checkout(repos)
  out <- repos %>% map_git("branch")

  expect_equal(out[[1]], c("  main", "* pr"))
  expect_equal(out[[2]], c("* main", "  pr"))
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

test_that("does not create two default branches but either main or master", {
  # Setup two minimal repositories.
  repos <- file.path(tempdir(), paste0("repo", 1:2))
  repos %>% walk(dir.create)
  on.exit(destroy(repos[[1]]), add = TRUE)
  on.exit(destroy(repos[[2]]), add = TRUE)

  repos %>%
    file.path("a-file.txt") %>%
    walk(file.create)
  repos %>%
    walk_git("init") %>%
    walk_git("config user.name Jerry") %>%
    walk_git("config user.email jerry@gmail.com") %>%
    walk_git("add .") %>%
    walk_git("commit -m 'New file'")

  repos %>% map_git("branch")
  checkout(repos)
  out <- repos %>% map_git("branch")
  only_1_default_branch <- all(
    unlist(lapply(out, function(x) length(grepl("main|master", x)) == 1L))
  )

  expect_true(only_1_default_branch)
})
