#' Compute Summary Statistics for Numeric Variables
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param digits Number of digits after decimal to display
#'
#' @return A tibble
cb_summary_stats_numeric <- function(df, .x, digits = 2) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  median = sd = NULL

  # ===========================================================================
  # Calculate measures of interest
  # ===========================================================================
  x <- rlang::sym(.x)
  summary <- df %>%
    dplyr::summarise(
      Min    = min(!!x, na.rm = TRUE),
      Mean   = mean(!!x, na.rm = TRUE),
      Median = median(!!x, na.rm = TRUE),
      Max    = max(!!x, na.rm = TRUE),
      SD     = sd(!!x, na.rm = TRUE)
    ) %>%
    # Format output
    dplyr::mutate_all(round, digits = digits) %>%
    dplyr::mutate_all(format, nsmall = digits)

  # ===========================================================================
  # Return tibble of results
  # ===========================================================================
  summary
}
