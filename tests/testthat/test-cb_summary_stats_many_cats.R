df <- cb_summary_stats_many_cats(study, id)

testthat::test_that("Dimensions of the object returned by cb_summary_stats_many_cats are as expected", {
  rows    <- nrow(df)
  columns <- ncol(df)

  testthat::expect_equal(rows, 5L)
  testthat::expect_equal(columns, 4L)
})

testthat::test_that("The expected column names are returned by cb_summary_stats_many_cats", {
  testthat::expect_equal(names(df), c("lowest_cats", "lowest_freq", "highest_cats", "highest_freq" ))
})

testthat::test_that("The expected category levels are returned by cb_summary_stats_many_cats", {
  testthat::expect_equal(df$lowest_cats, c("1001", "1002", "1004", "1005", "1006"))
  testthat::expect_equal(df$highest_cats, c("1017", "1018", "1019", "1020", "Missing"))

  # Change the frequency of a category and retest
  study$id[1] <- "1002"
  df <- cb_summary_stats_many_cats(study, id)
  testthat::expect_equal(df$highest_cats, c("1018", "1019", "1020", "Missing", "1002"))
})

testthat::test_that("The expected frequencies are returned by cb_summary_stats_many_cats", {
  testthat::expect_equal(df$lowest_freq, rep(1, 5))
  testthat::expect_equal(df$highest_freq, rep(1, 5))

  # Change the frequency of a category and retest
  study$id[1] <- "1002"
  df <- cb_summary_stats_many_cats(study, id)
  testthat::expect_equal(df$highest_freq, c(1, 1, 1, 1, 2))
})

testthat::test_that("The n_extreme_cats parameter of cb_summary_stats_many_cats works as expected", {
  # Change the value of n_extreme_cats from 5 (default) to 6
  df <- cb_summary_stats_many_cats(study, id, n_extreme_cats = 6)
  testthat::expect_equal(df$lowest_cats, c("1001", "1002", "1004", "1005", "1006", "1007"))
  testthat::expect_equal(df$highest_cats, c("1016", "1017", "1018", "1019", "1020", "Missing"))
  testthat::expect_equal(df$lowest_freq, rep(1, 6))
  testthat::expect_equal(df$highest_freq, rep(1, 6))
})

testthat::test_that("The cb_summary_stats_many_cats works as expected when .x is a factor", {
  # Change id to a factor
  study <- study %>% dplyr::mutate(id_f = factor(id))
  df <- cb_summary_stats_many_cats(study, id_f)
  testthat::expect_equal(df$lowest_cats, c("1001", "1002", "1004", "1005", "1006"))
  testthat::expect_equal(df$highest_cats, c("1017", "1018", "1019", "1020", "Missing"))
  testthat::expect_equal(df$lowest_freq, rep(1, 5))
  testthat::expect_equal(df$highest_freq, rep(1, 5))
})

# =============================================================================
# Clean up
# =============================================================================
rm(df)
