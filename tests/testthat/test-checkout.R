test_that("with a non-repo errors gracefully", {
  non_repo <- temp_dir()
  on.exit(destroy(non_repo), add = TRUE)

  expect_error(checkout(non_repo), "not a git repo")
})

test_that("from inside the working directory, checkouts the current branch", {
  repo <- setup_repo(temp_dir())
  on.exit(destroy(repo), add = TRUE)

  oldwd <- getwd()
  setwd(repo)
  on.exit(setwd(oldwd), add = TRUE)
  checkout(repo)
  has_pr_branch <- any(grepl("* pr", git_map(repo, "branch")))

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
    git_walk("init --initial-branch=main") %>%
    git_walk("config user.name Jerry") %>%
    git_walk("config user.email jerry@gmail.com") %>%
    git_walk("add .") %>%
    git_walk("commit -m 'New file'")

  checkout(repos)
  out <- repos %>% git_map("branch")
  at_main <- all(grepl("* main", out, fixed = TRUE))
  at_master <- all(grepl("* master", out, fixed = TRUE))

  expect_true(at_main || at_master)
})

test_that("stays at the branch of repo if it's the wd", {
  repo <- temp_dir()
  setup_repo(repo)
  on.exit(destroy(repo), add = TRUE)

  oldwd <- getwd()
  setwd(repo)
  on.exit(setwd(oldwd), add = TRUE)
  checkout(repo)

  out <- system("git branch", intern = TRUE)
  expect_equal(out, c("  main", "* pr"))
})

test_that("with uncommited changes throws an error", {
  repo <- setup_repo(temp_dir())
  on.exit(destroy(repo), add = TRUE)
  writeLines("change but don't commit", file.path(repo, "a"))

  expect_error(checkout(repo), "uncommited changes")
})

test_that("returns repos invisibly", {
  repo <- setup_repo(temp_dir())
  on.exit(destroy(repo), add = TRUE)

  expect_invisible(checkout(repo))
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
    git_walk("init --initial-branch=main") %>%
    git_walk("config user.name Jerry") %>%
    git_walk("config user.email jerry@gmail.com") %>%
    git_walk("add .") %>%
    git_walk("commit -m 'New file'")

  repos %>% git_map("branch")
  checkout(repos)
  out <- repos %>% git_map("branch")
  only_1_default_branch <- all(
    unlist(lapply(out, function(x) length(grepl("main|master", x)) == 1L))
  )

  expect_true(only_1_default_branch)
})
