df <- cb_summary_stats_time(study, date, digits = 2)

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
  df <- cb_summary_stats_time(study, date, digits = 3)
  testthat::expect_equal(df$Percentage, c("10.000", "15.000", "10.000"))
})

# =============================================================================
# Clean up
# =============================================================================
rm(df)

