# =============================================================================
# Make sure to wrap column names in quotes because that's how it's being handed
# down from codebook via cb_add_summary_stats
# =============================================================================

df <- cb_summary_stats_time(study, "date", digits = 2)

testthat::test_that("Dimensions of the object returned by cb_summary_stats_time are as expected", {
  testthat::expect_equal(nrow(df), 3L)
  testthat::expect_equal(ncol(df), 4L)
})

testthat::test_that("The expected column names are returned by cb_summary_stats_time", {
  testthat::expect_equal(names(df), c("Statistic", "Value", "Frequency", "Percentage" ))
})

testthat::test_that("The expected statistic labels are returned by cb_summary_stats_time", {
  testthat::expect_equal(df$Statistic, c("Minimum", "Mode", "Maximum"))
})

testthat::test_that("The expected default results are returned by cb_summary_stats_time", {
  testthat::expect_equal(df$Value,    c("2021-09-21", "2021-09-23", "2021-10-26"))
  testthat::expect_equal(df$Frequency, c("2", "3", "2"))
  testthat::expect_equal(df$Percentage, c("10.00", "15.00", "10.00"))
})

testthat::test_that("The digits parameter of cb_summary_stats_time works as expected", {
  # Change the value of digits from 2 (default) to 3
  df <- cb_summary_stats_time(study, "date", digits = 3)
  testthat::expect_equal(df$Percentage, c("10.000", "15.000", "10.000"))
})

# Issue #15: Make time appear in a human readable format
testthat::test_that("Time appears in a human readable format", {
  df <- cb_summary_stats_time(study, "time")
  testthat::expect_equal(df$Value, c("08:37:26", "All 20 values", "16:59:31"))
})

# Update `cb_summary_stats_time()`. Previously, if the mode value for a
# date/time column was NA, then the Value in the summary stats table looked
# blank. Now, the mode of non-missing values is returned instead. Additionally,
# if all values are `NA`, then the summary stats table says that explicitly.
testthat::test_that("NA values are ignored in date/time columns", {
  df <- data.frame(time = hms::as_hms(c("08:37:26", NA, NA)))
  df <- cb_summary_stats_time(df, "time")
  testthat::expect_equal(df$Value, c("08:37:26", "All 1 values", "08:37:26"))
})

testthat::test_that("All NA values in date/time columns produces expected result", {
  df <- data.frame(time = hms::as_hms(c(NA, NA, NA)))
  df <- cb_summary_stats_time(df, "time")
  testthat::expect_equal(df$Value, c("All values are missing", "All values are missing", "All values are missing"))
})

# =============================================================================
# Clean up
# =============================================================================
rm(df)

