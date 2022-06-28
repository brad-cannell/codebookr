#' Format Data Frame Attributes Flextable
#'
#' @param ft A flextable object
#'
#' @return A flextable object
#' @importFrom dplyr %>%
cb_theme_df_attributes <- function(ft) {

  ft <- ft %>%
    # Delete the header row
    flextable::delete_part(part = "header") %>%
    # Set font to TNR 11
    flextable::font(fontname = "Times New Roman") %>%
    flextable::fontsize(size = 11) %>%
    # Left align text
    flextable::align(align = "left", part = "all") %>%
    # Bold text in first column
    flextable::bold(j = 1) %>%
    # Set the width of both columns
    flextable::width(width = 3.25) %>%

    # Format borders
    # Remove default borders
    flextable::border_remove() %>%
    # Add thick bottom border to header (not actually the header)
    flextable::hline(i = 1, border = officer::fp_border()) %>%
    # Add light gray vertical line
    flextable::vline(j = 1, border = officer::fp_border()) %>%
    flextable::border_outer(part = "all", border = officer::fp_border())

  # Return formatted flextable
  ft
}
