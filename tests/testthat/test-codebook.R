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

# In response to issue #52, test to make sure that the word "Codebook" is printed at the top of the document
testthat::test_that("The word 'Codebook' is printed at the top of the Word document", {
  # Create a test codebook.
  cb <- codebook(
    df = study,
    title = "My Example Study",
    subtitle = "A Subtitle for My Example Study Codebook",
    description = "Test description"
  )

  # Create a Word codebook as a tempfile
  cb_doc <- print(cb, tempfile(fileext = ".docx"))

  # Check for the word "Codebook" at the top of the file
  # Helpful website: http://cran.nexr.com/web/packages/officer/vignettes/officer_reader.html
  doc <- officer::read_docx(cb_doc)
  content <- officer::docx_summary(doc)
  paragraphs <- subset(content, content_type %in% "paragraph")

  # Run the test
  testthat::expect_true(paragraphs$text[1] == "Codebook")

  # Also test that for the title, subtitle, and description
  testthat::expect_true(paragraphs$text[2] == "My Example Study")
  testthat::expect_true(paragraphs$text[3] == "A Subtitle for My Example Study Codebook")
  testthat::expect_true(paragraphs$text[8] == "Test description")
})
