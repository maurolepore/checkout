Use case of ‘family’ and ‘checkout’: Local CI for ‘pacta’
================

This article shows a use case of the packages “family” and “checkout” to
work with the “pacta” family of repositories. The goal is to test if a
“work in progress” in one repo plays well with the stable version of the
other repos. It is like a local version of the continuous-integration
workflow we run on GitHub for PACTA\_analysis. It has some benefits
compared to running online:

-   It’s faster.
-   It works with uncommited changes on the focal repo.
-   It does not consume our time-quota for private repo gh-actions.

Setup.

``` r
library(magrittr)
library(family)
library(checkout)

# Helper
pick_pattern <- function(x, pattern) {
  grep(pattern, x, value = TRUE)
}
```

We start by telling the “family” package which family to focus on.

``` r
options(family.regexp = "^[.]pacta$")
siblings()
#> [1] "/home/mauro/git/create_interactive_report"
#> [2] "/home/mauro/git/PACTA_analysis"           
#> [3] "/home/mauro/git/pacta-data"               
#> [4] "/home/mauro/git/StressTestingModelDev"
```

Let’s do some work in “StressTestingModelDev/”. We could use `git` from
the terminal but here we’ll show off `git_walk()`; it is a thin wrapper
around `system("git -C <path> ...")`. Here we create and checkout a new
branch “demo-pr”; modify and commit a new file; and inspect the
`git log`.

``` r
# Pretend we are working from inside StressTestingModelDev/
StressTestingModelDev <- siblings() %>% 
  pick_pattern("StressTestingModelDev")
setwd(StressTestingModelDev)

StressTestingModelDev %>% 
  git_walk("checkout -b demo-pr")

# Make some change so we have something to commit
writeLines("Some text", file.path(StressTestingModelDev, "some-file.txt"))

StressTestingModelDev %>% 
  git_walk("add .") %>% 
  git_walk("commit -m 'Add some file with some text'") %>%
  # `verbose = TRUE` prints git's output to the console
  git_walk("log --oneline --decorate -1", verbose = TRUE)
#> $`/home/mauro/git/StressTestingModelDev`
#> [1] "19f6848 (HEAD -> demo-pr) Add some file with some text"
```

The other pacta siblings, say “pacta-data”, may be at a non-default
branch. Now it makes more sense to use `git_walk()` because it allows us
to work work with multiple repos at once.

``` r
siblings() %>% 
  pick_pattern("pacta-data") %>% 
  git_walk("checkout -b wip") %>%
  git_walk("branch", verbose = TRUE)
#> $`/home/mauro/git/pacta-data`
#> [1] "  master" "* wip"
```

`checkout()` helps you checkout the default branch of every repo –
except for the current working directory, which stays at the current
reference (e.g. the current branch or tag). This allow you to test the
effect of your current work in the context of the stable version of
related project. It is inspired by the `ref` argument of the GitHub
action `checkout`.

``` r
# Pretend we are working from inside StressTestingModelDev/
StressTestingModelDev <- siblings() %>% 
  pick_pattern("StressTestingModelDev")

setwd(StressTestingModelDev)
siblings() %>% 
  checkout()

current_branch <- "^[*] "
siblings(self = TRUE) %>%
  # Returns a list of characters, which you can operate on
  git_map("branch") %>% 
  lapply(pick_pattern, current_branch)
#> $`/home/mauro/git/create_interactive_report`
#> [1] "* master"
#> 
#> $`/home/mauro/git/PACTA_analysis`
#> [1] "* master"
#> 
#> $`/home/mauro/git/pacta-data`
#> [1] "* master"
#> 
#> $`/home/mauro/git/StressTestingModelDev`
#> [1] "* demo-pr"
```

We could now use this, for example, to test if out work in progress
plays well with the web tool. This is similar to what we would otherwise
do on a continuous integration workflow online.

``` r
PACTA_analysis <- siblings() %>% 
  pick_pattern("PACTA_analysis")

setwd(PACTA_analysis)
source(file.path(PACTA_analysis, "R", "source_web_tool_scripts.R"))
source_web_tool_scripts(1)
#> Testing: Rscript --vanilla web_tool_script_1.R TestPortfolio_Input
```

–

Cleanup.

``` r
siblings() %>% 
  pick_pattern("pacta-data") %>% 
  git_walk("checkout master") %>% 
  git_walk("branch -D wip")

siblings() %>% 
  pick_pattern("StressTestingModelDev") %>% 
  git_walk("checkout master") %>% 
  git_walk("branch -D demo-pr")
```
