# =============================================================================
# The values returned by cb_add_summary_stats_date, _few_cats, _many_cats, and
# numeric all have their own test files. There's no need to test them again
# here. Instead, we will test to make sure the arguments to
# cb_add_summary_stats are behaving as expected and that the correct classes
# are being added to the summary tables being returned. With the new class name
# first. The class issue is related to an error that beings with stop_vctrs():!
# x must be a vector, and is detailed here:
# https://github.com/brad-cannell/codebookr/issues/3
# =============================================================================

# Numeric
testthat::test_that("cb_add_summary_stats is adding the expected classes to each column", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "height")),
    c("summary_numeric", "tbl_df", "tbl", "data.frame" )
  )
})

# Many cats
testthat::test_that("cb_add_summary_stats is adding the expected classes to each column", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "id")),
    c("summary_many_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# Few cats
testthat::test_that("cb_add_summary_stats is adding the expected classes to each column", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "sex")),
    c("summary_few_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# Time
testthat::test_that("cb_add_summary_stats is adding the expected classes to each column", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "date")),
    c("summary_time", "tbl_df", "tbl", "data.frame" )
  )
})


# =============================================================================
# Testing the flow logic of cb_add_summary_stats
#
# The input to cb_add_summary_stats is a data frame and a column from that
# data frame in the format cb_add_summary_stats(study, "id"). The column name
# is a character string because it is passed from a for loop in the codebook
# function.
#
# The purpose of cb_add_summary_stats is to attempt to figure out whether the
# column is:
# 1. Numeric
# 2. Categorical - many categories (e.g. participant id)
# 3. Categorical - few categories (e.g. gender)
# 4. Time - including dates
# This matters because the table of summary stats shown in the codebook
# document depends on the value cb_add_summary_stats chooses.
#
# The user can tell the cb_add_summary_stats function what to choose explicitly
# by giving the column a col_type attribute set to one of the following values:
# 1. Numerical,
#    study <- cb_add_col_attributes(study, height, col_type = "numeric")
# 2. Categorical
#    study <- cb_add_col_attributes(study, id, col_type = "categorical")
#    (we describe how many categories vs few categories is determined below)
# 3. Time
#    study <- cb_add_col_attributes(study, date, col_type = "time")
#
# If the user does not explicitly set the col_type attribute to one of these
# values, then cb_add_summary_stats will guess which col_type attribute to
# assign to each column based on the column's class and the number of unique
# non-missing values the it has.
#
# However, the number of unique non-missing values isn't used in an absolute
# way (e.g., 10 or more unique values is ALWAYS many_cats). Instead, the number
# of unique non-missing values used relative to the values passed to the
# many_cats parameter and/or the num_to_cat parameter -- depending on the class
# of the column.
#
# All of this flow logic takes place in the "Determine type of variable"
# section of cb_add_summary_stats. Here, we test to make sure it is working
# as expected when many_cats and num_to_cat are left at their default values.
# =============================================================================

# -----------------------------------------------------------------------------
# Check for user-set col_type
# -----------------------------------------------------------------------------

# Numeric
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  study <- study %>% cb_add_col_attributes(height, col_type = "numeric")
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "height")),
    c("summary_numeric", "tbl_df", "tbl", "data.frame" )
  )
})

# Many cats
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  study <- study %>% cb_add_col_attributes(id, col_type = "categorical")
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "id")),
    c("summary_many_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# Few cats
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  study <- study %>% cb_add_col_attributes(likert, col_type = "categorical")
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "likert")),
    c("summary_few_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# Time
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  study <- study %>% cb_add_col_attributes(date, col_type = "time")
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "date")),
    c("summary_time", "tbl_df", "tbl", "data.frame" )
  )
})

# -----------------------------------------------------------------------------
# If the col_type attribute was NOT set by the user (guessing)
# -----------------------------------------------------------------------------

# AND class = "logical"
# Logical can only take three values (T/F/NA), so it should always be
# few_cats. Theoretically, someone could set many_cats to 1 and this
# would return unexpected results (few_cats instead of many_cats),
# but that seems unlikely in practice.
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "outcome")),
    c("summary_few_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "character"
# AND the number of unique non-missing values is >= many_cats
# THEN the col_type should be set to many_cats
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "id")),
    c("summary_many_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "character"
# AND the number of unique non-missing values is < many_cats
# THEN the col_type should be set to few_cats
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  # Coerce likert to a character vector for testing
  study <- study %>%
    dplyr::mutate(likert = as.character(likert))
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "likert")),
    c("summary_few_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "factor"
# AND the number of unique non-missing values is >= many_cats
# THEN the col_type should be set to many_cats
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  # Coerce days to a factor vector for testing
  study <- study %>%
    dplyr::mutate(days = factor(days))
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "days")),
    c("summary_many_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "factor"
# AND the number of unique non-missing values is < many_cats
# THEN the col_type should be set to few_cats
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  # Coerce likert to a factor vector for testing
  study <- study %>%
    dplyr::mutate(likert = factor(likert))
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "likert")),
    c("summary_few_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "integer" OR class == "numeric"
# AND the number of unique non-missing values is < num_to_cat
# AND the number of unique non-missing values is >=  many_cats
# THEN the col_type should be set to many_cats
# This can't happen without adjusting the default values of num_to_cat and
# many_cats. A variable can't simultaneously have < 4 unique values and
# >= 10 unique values.
# Test this below

# AND class = "integer"
# AND the number of unique non-missing values is < num_to_cat
# AND the number of unique non-missing values is <  many_cats
# THEN the col_type should be set to few_cats
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  # Create a test variable that meets this criteria
  study <- study %>%
    dplyr::mutate(three_cats = sample(1L:3L, 20, TRUE))
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "three_cats")),
    c("summary_few_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "numeric"
# AND the number of unique non-missing values is < num_to_cat
# AND the number of unique non-missing values is <  many_cats
# THEN the col_type should be set to few_cats
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  # Create a test variable that meets this criteria
  study <- study %>%
    dplyr::mutate(three_cats = sample(1:3, 20, TRUE))
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "three_cats")),
    c("summary_few_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "integer"
# AND the number of unique non-missing values is > num_to_cat
# THEN the col_type should be set to numeric
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "days")),
    c("summary_numeric", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "numeric"
# AND the number of unique non-missing values is > num_to_cat
# THEN the col_type should be set to numeric
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "height")),
    c("summary_numeric", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "Date"
# THEN the col_type should be set to time
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "date")),
    c("summary_time", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "POSIXct"
# THEN the col_type should be set to time
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  study <- study %>% dplyr::mutate(date = as.POSIXct(date))
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "date")),
    c("summary_time", "tbl_df", "tbl", "data.frame" )
  )
})

# AND class = "hms"
# THEN the col_type should be set to time
testthat::test_that("The the flow logic of cb_add_summary_stats is working as expected", {
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "time")),
    c("summary_time", "tbl_df", "tbl", "data.frame" )
  )
})


# =============================================================================
# Testing the many_cats argument, which partially adjusts the categorization of
# variables. The way in which cb_add_summary_stats categorizes a variable
# determines which summary statistics are calculated for its summary table in
# the codebook.
#
# The many_cats argument sets the cutoff value that partially (i.e., along with
# the col_type attribute) determines whether cb_add_summary_stats will
# categorize the variable as categorical with few categories or categorical
# with many categories. The number of categories that constitutes "many" is
# defined by the value passed to the many_cats argument. The default is 10.
# =============================================================================

# If the col_type attribute is set to "categorical" and the number of unique
# non-missing values is < many_cats, then the col_type should be set to
# few_cats
testthat::test_that("The many_cats argument is working as expected", {
  study <- cb_add_col_attributes(study, id, col_type = "categorical")
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "id", many_cats = 30)),
    c("summary_few_cats", "tbl_df", "tbl", "data.frame" )
  )
})

# If the col_type attribute is set to "categorical" and the number of unique
# non-missing values is >= many_cats, then the col_type should be set to
# many_cats
# We also have to change n_extreme_cats to prevent an error
testthat::test_that("The many_cats argument is working as expected", {
  study <- cb_add_col_attributes(study, sex, col_type = "categorical")
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "sex", many_cats = 1, n_extreme_cats = 1)),
    c("summary_many_cats", "tbl_df", "tbl", "data.frame" )
  )
})


# =============================================================================
# Testing the num_to_cat argument, which partially adjusts the categorization of
# variables. The way in which cb_add_summary_stats categorizes a variable
# determines which summary statistics are calculated for its summary table in
# the codebook.
#
# The num_to_cat argument sets the cutoff value that partially (i.e., along with
# the col_type attribute) determines whether cb_add_summary_stats will
# categorize a numeric as categorical. If the col_type attribute is not set for
# a column AND the number of unique non-missing values is <= num_to_cat, then
# cb_add_summary_stats will guess that the variable is categorical. The default
# value for num_to_cat is 4.
# =============================================================================

# IF class = "integer" OR class == "numeric"
# AND the number of unique non-missing values is > num_to_cat
# THEN the col_type should be set to numeric
testthat::test_that("The num_to_cat argument is working as expected", {
  # Create a test variable that wouldn't meet this criteria without changing
  # num_to_cat
  study <- study %>%
    dplyr::mutate(three_cats = sample(1:3, 20, TRUE))
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "three_cats", num_to_cat = 2)),
    c("summary_numeric", "tbl_df", "tbl", "data.frame" )
  )
})

# IF class = "integer" OR class == "numeric"
# AND the number of unique non-missing values is < num_to_cat
# AND the number of unique non-missing values is >=  many_cats
# THEN the col_type should be set to many_cats
# This can't happen without adjusting the default values of num_to_cat and
# many_cats both. A variable can't simultaneously have < 4 unique values and
# >= 10 unique values.
testthat::test_that("The num_to_cat argument is working as expected", {
  # Create a test variable that meets this criteria
  study <- study %>%
    dplyr::mutate(six_cats = sample(1:6, 20, TRUE))
  testthat::expect_equal(
    class(cb_add_summary_stats(study, "six_cats", num_to_cat = 10, many_cats = 5)),
    c("summary_many_cats", "tbl_df", "tbl", "data.frame" )
  )
})



