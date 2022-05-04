#' Optionally Add Title and Subtitle to Codebook
#'
#' This function is not intended to be a stand-alone function. It is indented
#' to be used by the `codebook` function.
#'
#' @param rdocx rdocx object created with `officer::read_docx()`
#' @param title Optional title
#' @param subtitle Optional subtitle
#'
#' @return rdocx object
cb_add_title <- function(rdocx, title = NA, subtitle = NA) {

  # ===========================================================================
  # Checks
  # ===========================================================================
  # Are title and subtitle given?
  is_title <- !is.na(title)
  is_subtitle <- !is.na(subtitle)

  # ===========================================================================
  # Create text formats
  # ===========================================================================
  font <- "Times New Roman"
  fp_title_14_bold <- officer::fp_text(font.size = 14, bold = TRUE, font.family = font)
  fp_title_12 <- officer::fp_text(font.size = 12, font.family = font)
  fp_title_11 <- officer::fp_text(font.size = 11, font.family = font)

  # ===========================================================================
  # Create text elements
  # ===========================================================================
  text_codebook <- officer::ftext("Codebook", prop = fp_title_14_bold)

  if (is_title) { # Title is optional
    text_title <- officer::ftext(title, prop = fp_title_12)
  }

  if (is_subtitle) { # Subtitle is optional
    text_subtitle <- officer::ftext(subtitle, prop = fp_title_11)
  }

  # ===========================================================================
  # Create paragraph formats
  # ===========================================================================
  fp_center <- officer::fp_par(text.align = "center")

  # ===========================================================================
  # Create paragraph elements
  # ===========================================================================
  text_codebook <- officer::fpar(text_codebook, fp_p = fp_center)

  if (is_title) {
    text_title <- officer::fpar(text_title, fp_p = fp_center)
  }

  if (is_subtitle) {
    text_subtitle <- officer::fpar(text_subtitle, fp_p = fp_center)
  }

  # ===========================================================================
  # Add paragraph elements to the rdocx object
  # ===========================================================================
  rdocx <- rdocx %>%
    officer::body_add_fpar(text_codebook)

  if (is_title) {
    rdocx <- rdocx %>%
      officer::body_add_fpar(text_title)
  }

  if (is_subtitle) {
    rdocx <- rdocx %>%
      officer::body_add_fpar(text_subtitle)
  }

  # Add an empty line after the title/subtitle
  rdocx <- rdocx %>%
    officer::body_add_par("")

  # ===========================================================================
  # Return rdocx object that will later be used to create the Word document
  # ===========================================================================
  rdocx
}
