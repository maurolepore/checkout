
<!-- README.md is generated from README.Rmd. Please edit that file -->

# checkout

<!-- badges: start -->

[![R-CMD-check](https://github.com/maurolepore/checkout/workflows/R-CMD-check/badge.svg)](https://github.com/maurolepore/checkout/actions)
[![Codecov test
coverage](https://codecov.io/gh/maurolepore/checkout/branch/main/graph/badge.svg)](https://codecov.io/gh/maurolepore/checkout?branch=main)
[![CRAN
status](https://www.r-pkg.org/badges/version/checkout)](https://CRAN.R-project.org/package=checkout)
<!-- badges: end -->

The goal of this package is to checkout a set of git repositories in a
way similar to <https://github.com/actions/checkout>, to reproduce
locally what you may usually do in GitHub actions. It is most useful to
test locally the latest commit of the working directory in the context
of the master branch of one or multiple other repositories.

## Installation

You can install the development version of checkout from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("maurolepore/checkout")
```

## Example

``` r
library(checkout)
library(magrittr)

# Helper
walk <- function(x, f, ...) {
  lapply(x, f, ...)
  invisible(x)
}
```

`git_walk()` and `git_map()` help you work with multiple Git
repositories at once. `git_walk()` is primarily called for its side
effects; here we use it to setup two minimal repositories.

``` r
repos <- file.path(tempdir(), paste0("repo", 1:2))
repos %>% walk(dir.create)
repos %>% file.path("a-file.txt") %>% walk(file.create)
repos
#> [1] "/tmp/Rtmp5EiryS/repo1" "/tmp/Rtmp5EiryS/repo2"

repos %>%
  git_walk("init --initial-branch=main") %>%
  git_walk("config user.name Jerry") %>%
  git_walk("config user.email jerry@gmail.com") %>%
  git_walk("add .") %>%
  git_walk("commit -m 'Add a-file.txt'") %>%
  # Each repo now has a commit
  git_walk("log --oneline -n 1 --decorate", verbose = TRUE)
#> $`/tmp/Rtmp5EiryS/repo1`
#> [1] "0b72ce9 (HEAD -> main) Add a-file.txt"
#> 
#> $`/tmp/Rtmp5EiryS/repo2`
#> [1] "0b72ce9 (HEAD -> main) Add a-file.txt"
```

-   `checkout()` is inspired by the `ref` argument of
    <https://github.com/actions/checkout> and helps work locally in a
    way similar to GitHub actions. If we set the directory at `repo1`,
    it stays at the branch `pr`, whereas the `repo2` changes to the
    branch `master` (or `main`).

``` r
oldwd <- getwd()
setwd(repos[[1]])

repos %>% git_walk("checkout -b pr")

# Compare before and after `checkout()`
repos %>% git_walk("branch", verbose = TRUE)
#> $`/tmp/Rtmp5EiryS/repo1`
#> [1] "  main" "* pr"  
#> 
#> $`/tmp/Rtmp5EiryS/repo2`
#> [1] "  main" "* pr"
repos %>% checkout()
repos %>% git_walk("branch", verbose = TRUE)
#> $`/tmp/Rtmp5EiryS/repo1`
#> [1] "  main" "* pr"  
#> 
#> $`/tmp/Rtmp5EiryS/repo2`
#> [1] "* main" "  pr"

# Cleanup
setwd(oldwd)
repos %>% walk(unlink, recursive = TRUE)
```
