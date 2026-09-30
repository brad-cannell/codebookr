# Contributing to codebookr

Thank you for your interest in contributing to `codebookr`. Bug reports,
documentation improvements, and pull requests are welcome.

## Scope

`codebookr` creates codebooks that describe the shape and content of a
data set as it is stored. Before proposing a new feature, please check
that it fits within this scope:

- **In scope:** Reporting what is in the data. For example, column
  attributes, value labels, counts and percentages of each observed
  value (including missing values), and summaries of the range and
  distribution of values.
- **Out of scope:** Making analysis decisions on the user’s behalf. For
  example, deciding which values count as missing or valid, excluding
  rows from a denominator, recoding or collapsing categories, or
  computing statistics that depend on those choices.

As a rule of thumb, `codebookr` excludes missing values from a
calculation only when the statistic cannot be computed otherwise (e.g.,
a mean). In those cases, the number of missing values is always reported
alongside it.

If you’re unsure whether an idea fits, please open an issue to discuss
it before writing code. That way nobody spends time on a pull request
that falls outside the package’s scope.

## Pull requests

- Add or update tests in `tests/testthat/` for any change in behavior.
- If you change roxygen comments or function arguments, run
  `devtools::document()` so the files in `man/` stay in sync.
- Add a bullet to `NEWS.md` describing any user-facing change.
- Make sure `devtools::check()` runs without errors or warnings.
