#' Create Formatted Section Header
#'
#' @param rdocx rdocx object created with `officer::read_docx()`
#' @param text Text of section header
#'
#' @return rdocx object
#' @importFrom dplyr %>%
#' @keywords internal
cb_add_section_header <- function(rdocx, text = NA) {

  # ===========================================================================
  # Create text formats
  # ===========================================================================
  font <- "Times New Roman"
  fp_tnr_11 <- officer::fp_text(font.size = 11, bold = TRUE, font.family = font)

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
