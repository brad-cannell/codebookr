# =============================================================================
# Study data
# This is the code to create the study data - a simulated dataset that can be
# used to demonstrate how to use the codebook package.
# Created: 2022-04-04
# Brad Cannell
# =============================================================================

library(dplyr, warn.conflicts = FALSE)
library(hms, warn.conflicts = FALSE)

set.seed(123)
study <- tibble(
  id        = as.character(seq(1001, 1020, 1)),
  address   = paste("101", LETTERS[1:20], "st."),
  sex       = factor(sample(c("Female", "Male"), 20, TRUE)),
  date      = sample(seq.Date(as.Date("2021-09-15"), as.Date("2021-10-26"), "day"), 20, TRUE),
  sec       = sample(0:60, 20, TRUE),
  min       = sample(0:60, 20, TRUE),
  hour      = sample(8:16, 20, TRUE),
  time      = hms(sec, min, hour),
  # Combine date and time into a POSIXct variable for testing
  date_time = paste(date, time) %>% as.POSIXct(),
  days      = sample(1L:21L, 20L, TRUE),
  height    = rnorm(20, 71, 10),
  likert    = sample(1:5, 20, TRUE),
  outcome   = sample(c(TRUE, FALSE), 20, TRUE)
)

# Keep vars of interest
study <- study %>%
  select(-sec, -min, -hour)

# Add missing values for testing
study$id[3] <- NA
study$sex[4] <- NA
study$date[5] <- NA
study$days[6] <- NA
study$height[7] <- NA


# Add the simulated data to the data directory.
usethis::use_data(study, overwrite = TRUE)

# Export a csv file that we can import into Stata.
# We use the Stata data for one of the examples in README.
readr::write_csv(study, "inst/extdata/study.csv")
