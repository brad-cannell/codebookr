#' Format Column Attributes Flextable
#'
#' @param ft A flextable object
#'
#' @return A flextable object
cb_theme_col_attr <- function(ft) {

  # Set border attributes
  border_thick <- officer::fp_border(color = "black", width = 3)
  border_lt_gr <- officer::fp_border(color = "gray80", width = 1)

  ft <- ft %>%
    # Delete the header row
    flextable::set_header_labels(Attribute = NULL, value = NULL) %>%
    # Set the width of both columns
    flextable::width(width = c(2.31, 4.18)) %>%

    # Format font
    # Set font to TNR 11
    flextable::font(fontname = "Times New Roman") %>%
    flextable::fontsize(size = 11) %>%
    # Left align text
    flextable::align(align = "left", part = "all") %>%
    # Bold text in first column
    flextable::bold(i=1) %>%

    # Format borders
    # Remove default borders
    flextable::border_remove() %>%
    # Add thick top border to header (not actually the header)
    flextable::hline_top(border = border_thick) %>%
    # Add thick bottom border to header (not actually the header)
    flextable::hline(i = 1, border = border_thick) %>%
    # Add light gray vertical line
    flextable::vline(j = 1, border = border_lt_gr) %>%

    # Set background color
    flextable::bg(i = 1, bg = "gray95")


  # Return formatted flextable
  ft
}
