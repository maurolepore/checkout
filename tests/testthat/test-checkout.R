library(gert)

test_that("with the current working directory does nothing", {
  oldwd <- getwd()
  repo <- file.path(tempdir(), "myrepo")
  git_init(repo)
  setwd(repo)

  # Set a user if no default
  if (!user_is_configured()) {
    git_config_set("user.name", "Jerry")
    git_config_set("user.email", "jerry@gmail.com")
  }



  file.create("a")
  gert::git_add("a")
  id <- gert::git_commit("New file")

  checkout(repo)
  expect_equal(gert::git_commit_id(repo = repo), id)



  # cleanup
  setwd(oldwd)
  unlink(repo, recursive = TRUE)
  })
