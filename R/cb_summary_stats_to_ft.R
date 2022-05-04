#' Create Formatted Flextable From Summary Statistics
#'
#' @param df Data frame of summary statistics
#' @param ... Other stuff
#' @param col_width Set the width of the column that will appear in the Word table
#'
#' @return Flextable object
#' @importFrom dplyr %>%

# =============================================================================
# S3 Generic function
# =============================================================================
cb_summary_stats_to_ft <- function(df, ...) {
  UseMethod("cb_summary_stats_to_ft")
}


# =============================================================================
# Method for class summary_numeric
# =============================================================================
#' @inheritParams cb_summary_stats_to_ft
#' @export
#' @rdname cb_summary_stats_to_ft

cb_summary_stats_to_ft.summary_numeric <- function(df, col_width = 1.3) {

  ft <- df %>%
    flextable::regulartable() %>%
    # Set font to TNR 11
    flextable::font(fontname = "Times New Roman", part = "all") %>%
    flextable::fontsize(size = 11, part = "all") %>%
    # Center align text
    flextable::align(align = "center", part = "all") %>%
    # Bold header
    # bold(part = "header") %>%
    # Set the column width
    flextable::width(width = col_width) %>%

    # Format borders
    # Remove default borders
    flextable::border_remove() %>%
    # Add light gray top border
    flextable::hline_top(border = officer::fp_border(color = "gray80", width = 1), part = "all")

  # Return formatted flextable
  ft
}


# =============================================================================
# Method for class summary_many_cats
# =============================================================================
#' @inheritParams cb_summary_stats_to_ft
#' @export
#' @rdname cb_summary_stats_to_ft

cb_summary_stats_to_ft.summary_many_cats <- function(df, col_width = 1.62) {
  ft <- df %>%
    # Set all variables to character first to prevent adding trailing zeros
    dplyr::mutate_all(as.character) %>%
    flextable::regulartable() %>%
    # Change header text
    flextable::set_header_labels(
      lowest_cats  = "Categories with Smallest Values",
      lowest_freq  = "Frequency",
      highest_cats = "Categories with Largest Values",
      highest_freq = "Frequeny"
    ) %>%
    # Set font to TNR 11
    flextable::font(fontname = "Times New Roman", part = "all") %>%
    flextable::fontsize(size = 11, part = "all") %>%
    # Center align text
    flextable::align(align = "center", part = "all") %>%
    # Bold header
    # bold(part = "header") %>%
    # Set the column width
    flextable::width(width = col_width) %>%

    # Format borders
    # Remove default borders
    flextable::border_remove() %>%
    # Add light gray top border
    flextable::hline_top(border = officer::fp_border(color = "gray80", width = 1), part = "all")

  # Return formatted flextable
  ft
}


# =============================================================================
# Method for class summary_few_cats
# =============================================================================
#' @inheritParams cb_summary_stats_to_ft
#' @export
#' @rdname cb_summary_stats_to_ft

cb_summary_stats_to_ft.summary_few_cats <- function(df, col_width = 1.62) {

  ft <- df %>%
    flextable::regulartable() %>%
    # Change header text
    flextable::set_header_labels(
      cat      = "Categories",
      n        = "Frequency",
      percent  = "Percent",
      cum_freq = "Cumulative Frequency"
    ) %>%
    # Set font to TNR 11
    flextable::font(fontname = "Times New Roman", part = "all") %>%
    flextable::fontsize(size = 11, part = "all") %>%
    # Center align text
    flextable::align(align = "center", part = "all") %>%
    # Bold header row
    # bold(part = "header") %>%
    # Set the column width
    flextable::width(width = col_width) %>%

    # Format borders
    # Remove default borders
    flextable::border_remove() %>%
    # Add light gray top border
    flextable::hline_top(border = officer::fp_border(color = "gray80", width = 1), part = "all")

  # Return formatted flextable
  ft
}


# =============================================================================
# Method for class summary_time
# =============================================================================
#' @inheritParams cb_summary_stats_to_ft
#' @export
#' @rdname cb_summary_stats_to_ft

cb_summary_stats_to_ft.summary_time <- function(df, col_width = 1.62) {
  ft <- df %>%
    flextable::regulartable() %>%
    # Set font to TNR 11
    flextable::font(fontname = "Times New Roman", part = "all") %>%
    flextable::fontsize(size = 11, part = "all") %>%
    # Text alignment
    flextable::align(j = 2:4, align = "center", part = "all") %>%
    flextable::align(j = 1, align = "left", part = "all") %>%
    # Bold text
    # bold(part = "header") %>%
    # bold(j = 1, part = "body") %>%
    # Set the column width
    flextable::width(width = col_width) %>%

    # Format borders
    # Remove default borders
    flextable::border_remove() %>%
    # Add light gray top border
    flextable::hline_top(border = officer::fp_border(color = "gray80", width = 1), part = "all")

  # Return formatted flextable
  ft
}
