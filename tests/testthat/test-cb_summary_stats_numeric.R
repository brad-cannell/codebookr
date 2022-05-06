df <- cb_summary_stats_numeric(study, height, digits = 2)

testthat::test_that("Dimensions of the object returned by cb_summary_stats_numeric are as expected", {
  testthat::expect_equal(nrow(df), 1L)
  testthat::expect_equal(ncol(df), 5L)
})

testthat::test_that("The expected column names are returned by cb_summary_stats_numeric", {
  testthat::expect_equal(names(df), c("Min", "Mean", "Median", "Max", "SD"))
})

testthat::test_that("The expected default statistics are returned by cb_summary_stats_numeric", {
  testthat::expect_equal(df$Min, c("55.51"))
  testthat::expect_equal(df$Mean, c("72.33"))
  testthat::expect_equal(df$Median, c("70.71"))
  testthat::expect_equal(df$Max, c("92.69"))
  testthat::expect_equal(df$SD, c("9.76"))
})

testthat::test_that("The digits parameter of cb_summary_stats_numeric works as expected", {
  # Change the value of digits from 2 (default) to 3
  df <- cb_summary_stats_numeric(study, height, digits = 3)
  testthat::expect_equal(df$Min, c("55.512"))
  testthat::expect_equal(df$Mean, c("72.333"))
  testthat::expect_equal(df$Median, c("70.715"))
  testthat::expect_equal(df$Max, c("92.690"))
  testthat::expect_equal(df$SD, c("9.758"))
})

# =============================================================================
# Clean up
# =============================================================================
rm(df)
