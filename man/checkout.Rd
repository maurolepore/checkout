% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checkout.R
\name{checkout}
\alias{checkout}
\title{Checkout Git repositories}
\usage{
checkout(repos)
}
\arguments{
\item{repos}{Path to one or more Git repositories.}
}
\value{
Called for its side effect. Returns \code{repos} invisibly.
}
\description{
Checkout the \code{main} or \code{master} branch of the given Git repositories. But
stay on the current reference (e.g. branch) if checking out the repository
that called \code{checkout()}.
}
\examples{
library(magrittr)

# Helper
walk <- function(x, f, ...) {
  lapply(x, f, ...)
  invisible(x)
}

# Setup two minimal repositories.
repos <- file.path(tempdir(), paste0("repo", 1:2))
repos
repos \%>\% walk(dir.create)
repos \%>\%
  file.path("a-file.txt") \%>\%
  walk(file.create)
repos \%>\%
  walk_git("init") \%>\%
  walk_git("config user.name Jerry") \%>\%
  walk_git("config user.email jerry@gmail.com") \%>\%
  walk_git("add .") \%>\%
  walk_git("commit -m 'New file'")

# If we set the directory at `repo1`, it stays at the branch `pr`, whereas the
# `repo2` changes to the branch `master` (or `main`).

oldwd <- getwd()
setwd(repos[[1]])

repos \%>\% walk_git("checkout -b pr")

# Compare before and after `checkout()`
repos \%>\% walk_git("branch", verbose = TRUE)
repos \%>\% checkout()
repos \%>\% walk_git("branch", verbose = TRUE)

# Cleanup
setwd(oldwd)
repos \%>\% walk(unlink, recursive = TRUE)
}
