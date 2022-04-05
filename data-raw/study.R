# =============================================================================
# Study data
# This is the code to create the study data - a simulated dataset that can be
# used to demonstrate how to use the codebook package.
# Created: 2022-04-04
# Brad Cannell
# =============================================================================

library(dplyr, warn.conflicts = FALSE)

set.seed(123)
study <- tibble(
  id     = factor(seq(1001, 1020, 1)),
  gender = sample(c("Female", "Male"), 20, TRUE),
  date   = sample(seq.Date(as.Date("2021-09-15"), as.Date("2021-10-26"), "day"), 20, TRUE),
  height = rnorm(20, 71, 10)
)


# Add the simulated data to the data directory.
usethis::use_data(study, overwrite = TRUE)
