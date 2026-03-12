#' Create Formatted Flextable From Custom Summary Statistics
#'
#' @param df Data frame of summary statistics
#' @param ... Other stuff
#' @param col_width Set the width of the column that will appear in the Word
#' table
#'
#' @return Flextable object
#' @importFrom dplyr %>%
#' @keywords internal

cb_custom_summary_stats_to_ft <- function(df, col_width = 1.3, ...) {
  ft <- df %>%
    flextable::regulartable() %>%
    # Set font to TNR 11
    flextable::font(fontname = "Times New Roman", part = "all") %>%
    flextable::fontsize(size = 11, part = "all") %>%
    # Center align text
    flextable::align(align = "center", part = "all") %>%
    # Set the column width
    flextable::width(width = col_width) %>%

    # Format borders
    # Remove default borders
    flextable::border_remove() %>%
    # Add light gray top border
    flextable::hline_top(border = officer::fp_border(color = "gray80",
                                                     width = 1), part = "all")

  # Return formatted flextable
  ft
}
