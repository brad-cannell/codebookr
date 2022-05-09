# The codebook function expects the object passed to the df argument to be a
# data frame.
testthat::test_that("The check for a data frame works as expected", {
  # Should work
  df <- data.frame(x = letters, y = 1:26)
  testthat::expect_equal(class(codebook(df)), "rdocx")
})

testthat::test_that("The check for a data frame works as expected", {
  # Vector shouldn't work
  df <- 1:10
  testthat::expect_error(codebook(df), "Expecting df to be of class data.frame. Instead it was integer")
})

testthat::test_that("The check for a data frame works as expected", {
  # Piping in a data frame should throw a warning
  df <- data.frame(x = letters, y = 1:26)
  testthat::expect_message(df %>% codebook(), "The codebook function currently sees the name of the data frame you passed to the `df` argument as '.'. This is probably because you used a pipe to pass the data frame name into the codebook function. If you want the actual name of the data frame to be printed in the `Dataset name:` row of the metadata table, do not use a pipe to pass the data frame name into the codebook function.")
})
