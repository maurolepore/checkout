
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

This is a basic example which shows you how to solve a common problem:

``` r
library(checkout)
library(gert)
#> Linking to libgit2 v0.26.0, ssh support: YES
#> Global config: /home/mauro/.gitconfig
#> Default user: Mauro Lepore <maurolepore@gmail.com>
```

Setup two minimal repositories.

``` r
repo_a <- file.path(tempdir(), "repo_a")
dir.create(repo_a)
file.create(file.path(repo_a, "a-file.txt"))
#> [1] TRUE
git_init(repo_a)
git_add(".", repo = repo_a)
#>         file status staged
#> 1 a-file.txt    new   TRUE
git_commit_all("New file", repo = repo_a)
#> [1] "4107073d3271e6ad7c4a6c046239b459780b9921"

repo_b <- file.path(tempdir(), "repo_b")
dir.create(repo_b)
file.create(file.path(repo_b, "a-file.txt"))
#> [1] TRUE
git_init(repo_b)
git_add(".", repo = repo_b)
#>         file status staged
#> 1 a-file.txt    new   TRUE
git_commit_all("New file", repo = repo_b)
#> [1] "4107073d3271e6ad7c4a6c046239b459780b9921"
```

If we set the directory at `repo_a`, it stays at the branch `pr`,
whereas the `repo_b` changes to the branch `master` (or `main`).

``` r
setwd(repo_a)

git_branch_create("pr", checkout = TRUE, repo = repo_a)
git_branch_create("pr", checkout = TRUE, repo = repo_b)

# Before
git_branch(repo_a)
#> [1] "pr"
git_branch(repo_b)
#> [1] "pr"

checkout(c(repo_a, repo_b))

# After
git_branch(repo_a)
#> [1] "pr"
git_branch(repo_b)
#> [1] "main"
```

This behaviour is inspired by the `ref` argument of
<https://github.com/actions/checkout> and helps work locally in a way
similar to GitHub actions.