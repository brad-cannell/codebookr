#' Create Formatted Flextable From Custom Summary Statistics
#'
#' @param df Data frame of summary statistics
#' @param ... Other stuff
#' @param stats_df The data frame of statistics for a single variable that is to
#' be formatted.
#' @param custom_funcs A character vector of statistics that were run for the
#' column of interest which are also the column names for the input data frame
#' of summary statistics.
#' @param custom_funcs_labels A character vector of labels for the customized
#' summary statistics that will appear as the flextable header labels in the
#' resulting codebook.
#' @return Flextable object
#' @keywords internal

cb_custom_summary_stats_to_ft <- function(stats_df, custom_funcs, custom_funcs_labels) {
  # Create named list of headers and labels
  head_labs <- setNames(custom_funcs_labels, custom_funcs) |> as.list()

  # Set column width depending on the number of columns so that overall table
  # width is fixed at 6.5.
  col_width <- 6.5/ncol(stats_df)

  ft <- stats_df |>
    flextable::regulartable() |>
    # Set font to TNR 11
    flextable::font(fontname = "Times New Roman", part = "all") |>
    flextable::fontsize(size = 11, part = "all") |>
    # Center align text
    flextable::align(align = "center", part = "all") |>
    # Set the column width
    flextable::width(width = col_width) |>

    # Format borders
    # Remove default borders
    flextable::border_remove() |>
    # Add light gray top border
    flextable::hline_top(border = officer::fp_border(color = "gray80",
                                                     width = 1), part = "all") |>

    # Set header labels
    flextable::set_header_labels(values = head_labs)

  # Return formatted flextable
  ft
}
