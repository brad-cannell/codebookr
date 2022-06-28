# =============================================================================
# Unit tests for cb_get_col_attributes.
# This function is used inside of codebook() to get attribute values to be used
# for the column attributes table in the codebook document.
# =============================================================================

# Load data
data(study)

# Default usage
df <- cb_get_col_attributes(study, "id", keep_blank_attributes = FALSE)

testthat::test_that("Dimensions of the df returned by cb_get_col_attributes are as expected", {
  testthat::expect_equal(nrow(df), 4L)
  testthat::expect_equal(ncol(df), 2L)
})

testthat::test_that("Column attributes returned by cb_get_col_attributes are as expected", {
  testthat::expect_equal(
    df$Attribute,
    c("Column name:", "Data type:", "Unique non-missing value count:", "Missing value count:")
  )
  testthat::expect_equal(
    df$value,
    c("id", "Character", "19", "1")
  )
})


# Test keep blank attributes
df <- cb_get_col_attributes(study, "id", keep_blank_attributes = TRUE)

testthat::test_that("Dimensions of the df returned by cb_get_col_attributes are as expected", {
  testthat::expect_equal(nrow(df), 8L)
  testthat::expect_equal(ncol(df), 2L)
})

testthat::test_that("Column attributes returned by cb_get_col_attributes are as expected", {
  testthat::expect_equal(
    df$Attribute,
    c(
      "Column name:", "Column description:", "Source information:", "Column type:",
      "Data type:", "Unique non-missing value count:", "Missing value count:",
      "Value labels:"
    )
  )
  testthat::expect_equal(
    df$value,
    c("id", "", "", "", "Character", "19", "1", "")
  )
})


# =============================================================================
# Test haven labels
# When importing with haven, cb_get_col_attributes should automatically set the
# "Column description:" to the value of the `label` attribute and the value of
# "Value labels:" to the value of the `labels` attribute.
# =============================================================================
study <- haven::read_dta(system.file("extdata", "study.dta", package = "codebookr"))
df <- cb_get_col_attributes(study, "sex", keep_blank_attributes = FALSE)

testthat::test_that("Column description is as expected", {
  testthat::expect_equal(
    df$value[df$Attribute == "Column description:"],
    "Biological sex of the participant assigned at birth"
  )
})

testthat::test_that("Value labels: is as expected", {
  testthat::expect_equal(
    df$value[df$Attribute == "Value labels:"],
    "1 = Female"
  )
  testthat::expect_equal(
    df$value[df$Attribute == ""],
    "2 = Male"
  )
})


# =============================================================================
# Test overwriting
# When "label" and "description" both exist, description should win.
# =============================================================================
study <- haven::read_dta(system.file("extdata", "study.dta", package = "codebookr"))

# Add description attribute
attr(study$sex, "description") <- "Test"
df <- cb_get_col_attributes(study, "sex", keep_blank_attributes = FALSE)

testthat::test_that("Column description is as expected", {
  testthat::expect_equal(
    df$value[df$Attribute == "Column description:"],
    "Test"
  )
})

# =============================================================================
# Clean up
# =============================================================================
rm(df, study)
