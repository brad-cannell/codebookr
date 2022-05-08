# =============================================================================
# Make sure to wrap column names in quotes because that's how it's being handed
# down from codebook via cb_add_summary_stats
# =============================================================================

df <- cb_summary_stats_numeric(study, "height", digits = 2)

testthat::test_that("Dimensions of the object returned by cb_summary_stats_numeric are as expected", {
  testthat::expect_equal(nrow(df), 1L)
  testthat::expect_equal(ncol(df), 5L)
})

testthat::test_that("The expected column names are returned by cb_summary_stats_numeric", {
  testthat::expect_equal(names(df), c("Min", "Mean", "Median", "Max", "SD"))
})

testthat::test_that("The expected default statistics are returned by cb_summary_stats_numeric", {
  testthat::expect_equal(df$Min, c("58.79"))
  testthat::expect_equal(df$Mean, c("73.54"))
  testthat::expect_equal(df$Median, c("73.39"))
  testthat::expect_equal(df$Max, c("84.61"))
  testthat::expect_equal(df$SD, c("6.90"))
})

testthat::test_that("The digits parameter of cb_summary_stats_numeric works as expected", {
  # Change the value of digits from 2 (default) to 3
  df <- cb_summary_stats_numeric(study, "height", digits = 3)
  testthat::expect_equal(df$Min, c("58.793"))
  testthat::expect_equal(df$Mean, c("73.538"))
  testthat::expect_equal(df$Median, c("73.387"))
  testthat::expect_equal(df$Max, c("84.607"))
  testthat::expect_equal(df$SD, c("6.901"))
})

# =============================================================================
# Clean up
# =============================================================================
rm(df)
