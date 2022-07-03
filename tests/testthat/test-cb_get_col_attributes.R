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
  testthat::expect_equal(nrow(df), 9L)
  testthat::expect_equal(ncol(df), 2L)
})

testthat::test_that("Column attributes returned by cb_get_col_attributes are as expected", {
  testthat::expect_equal(
    df$Attribute,
    c(
      "Column name:", "Column description:", "Source information:", "Column type:",
      "Data type:", "Unique non-missing value count:", "Missing value count:",
      "Value labels:", "Skip pattern:"
    )
  )
  testthat::expect_equal(
    df$value,
    c("id", "", "", "", "Character", "19", "1", "", "")
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

testthat::test_that("Value labels are as expected", {
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
# When "labels" and "value_labels" both exist, value_labels should win.
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

# Add value_labels attribute
attr(study$sex, "value_labels") <- c("no" = 1, "yes" = 2)
df <- cb_get_col_attributes(study, "sex", keep_blank_attributes = FALSE)

testthat::test_that("Value labels are as expected", {
  testthat::expect_equal(
    df$value[df$Attribute == "Value labels:"],
    "1 = no"
  )
  testthat::expect_equal(
    df$value[df$Attribute == ""],
    "2 = yes"
  )
})


# =============================================================================
# Test values passed to value_labels
# Check to make sure value_labels is a named vector/list with no missing
# =============================================================================
study <- haven::read_dta(system.file("extdata", "study.dta", package = "codebookr"))

# Named vector should work
attr(study$sex, "value_labels") <- c("Male" = 1, "Female" = 2)
df <- cb_get_col_attributes(study, "sex", keep_blank_attributes = FALSE)
testthat::test_that("Value labels error as expected", {
  testthat::expect_equal(
    df$value[df$Attribute == "Value labels:"],
    "1 = Male"
  )
  testthat::expect_equal(
    df$value[df$Attribute == ""],
    "2 = Female"
  )
})

# Named list should work
attr(study$sex, "value_labels") <- list("Male" = 1, "Female" = 2)
df <- cb_get_col_attributes(study, "sex", keep_blank_attributes = FALSE)
testthat::test_that("Value labels error as expected", {
  testthat::expect_equal(
    df$value[df$Attribute == "Value labels:"],
    "1 = Male"
  )
  testthat::expect_equal(
    df$value[df$Attribute == ""],
    "2 = Female"
  )
})

# Unnamed vector should not work
attr(study$sex, "value_labels") <- c(0, 1)
testthat::test_that("Value labels error as expected", {
  testthat::expect_error(
    cb_get_col_attributes(study, "sex", keep_blank_attributes = FALSE)
  )
})

# Partially named vector should not work
attr(study$sex, "value_labels") <- c("no" = 0, 1)
testthat::test_that("Value labels error as expected", {
  testthat::expect_error(
    cb_get_col_attributes(study, "sex", keep_blank_attributes = FALSE)
  )
})

# Non-vector/non-list object should not work
attr(study$sex, "value_labels") <- matrix(c(1, 1, 1, 1))
testthat::test_that("Value labels error as expected", {
  testthat::expect_error(
    cb_get_col_attributes(study, "sex", keep_blank_attributes = FALSE)
  )
})


# =============================================================================
# Clean up
# =============================================================================
rm(df, study)
