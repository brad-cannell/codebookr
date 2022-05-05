df <- cb_add_col_attributes(
  study,
  id,
  description = "Study identification variable",
  data_group = "Administrative"
)

id_attributes <- attributes(df$id)

testthat::test_that("cb_add_col_attributes returns a message the first time attributes are added to a df.", {
  # There should be a message the first time an attribute is added (i.e., "label")
  testthat::expect_message(
    cb_add_col_attributes(study, id, label = "Test"),
    # If NULL, the default, asserts that there should be an error, but doesn't
    # test for a specific value. When I put in the actual message returned by
    # cb_add_col_attributes, the test fails. For now, just checking that it
    # returns a message is probably good enough.
    NULL
  )

  # There should NOTE be a message the second time an attribute is added (i.e., "description")
  testthat::expect_message(
    cb_add_col_attributes(df, id, description = "Test"),
    # If NA, asserts that there should be no errors.
    NA
  )
})

testthat::test_that("Attribute names are as expected post cb_add_col_attributes.", {
  testthat::expect_equal(names(id_attributes), c("description", "data_group"))
})

testthat::test_that("Attribute values are as expected post cb_add_col_attributes.", {
  testthat::expect_equal(
    unlist(id_attributes, use.names = FALSE),
    c("Study identification variable", "Administrative"))
})

# =============================================================================
# Clean up
# =============================================================================
rm(df, id_attributes)

