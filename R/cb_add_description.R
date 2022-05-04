#' Add Description Text to Codebook
#'
#' Basically, just checks for the number of paragraphs in the description and
#' then runs cb_add_text for each one.
#'
#' @param rdocx rdocx rdocx object created with `officer::read_docx()`
#' @param description Text description of the dataset
#'
#' @return rdocx object
cb_add_description <- function(rdocx, description) {

  # ===========================================================================
  # Split the description at line breaks (paragraphs)
  # ===========================================================================
  description_split <- stringr::str_split(string = description, pattern = "\\n")
  description_split <- unlist(description_split)

  # ===========================================================================
  # Add each paragraph to the codebook shell
  # ===========================================================================
  for (i in seq_along(description_split)) {
    # Remove empty paragraphs
    if (nchar(description_split[i]) != 0) {
      rdocx <- cb_add_text(rdocx, description_split[i])
    }
  }

  # ===========================================================================
  # Return rdocx object that will be added to the Word document
  # ===========================================================================
  rdocx
}
