#' Compute Summary Statistics for Numeric Variables
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param digits Number of digits after decimal to display
#'
#' @return A tibble
#' @family add_summary_stats
#' @importFrom dplyr %>%
cb_summary_stats_numeric <- function(df, .x, digits = 2) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  median = sd = .data = NULL

  # ===========================================================================
  # Calculate measures of interest
  # ===========================================================================
  summary <- df %>%
    dplyr::summarise(
      Min    = min(.data[[.x]], na.rm = TRUE),
      Mean   = mean(.data[[.x]], na.rm = TRUE),
      Median = median(.data[[.x]], na.rm = TRUE),
      Max    = max(.data[[.x]], na.rm = TRUE),
      SD     = sd(.data[[.x]], na.rm = TRUE)
    ) %>%
    # Format output
    dplyr::mutate(dplyr::across(dplyr::everything(), round, digits = digits)) %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), format, nsmall = digits))

  # ===========================================================================
  # Return tibble of results
  # ===========================================================================
  summary
}

# For testing
# data(study)
# cb_summary_stats_numeric(study, height)
