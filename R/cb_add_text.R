#' Create Formatted Text
#'
#' @param rdocx rdocx rdocx object created with `officer::read_docx()`
#' @param text Arbitrary text
#'
#' @return rdocx object
#' @importFrom dplyr %>%
cb_add_text <- function(rdocx, text = NA) {

  # ===========================================================================
  # Create text formats
  # ===========================================================================
  font <- "Times New Roman"
  fp_tnr_11 <- officer::fp_text(font.size = 11, font.family = font)

  # ===========================================================================
  # Create formatted text elements
  # ===========================================================================
  text <- officer::ftext(text, prop = fp_tnr_11)

  # ===========================================================================
  # Create paragraph elements
  # ===========================================================================
  text <- officer::fpar(text)

  # ===========================================================================
  # Add text to the rdocx object
  # ===========================================================================
  rdocx <- rdocx %>%
    officer::body_add_par("") %>% # Add space above
    officer::body_add_fpar(text)

  # ===========================================================================
  # Return rdocx object that will be added to the Word document
  # ===========================================================================
  rdocx
}
