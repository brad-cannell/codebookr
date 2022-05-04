#' Compute Summary Statistics for Categorical Variables with Few Categories
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param digits Number of digits after decimal to display
#'
#' @return A tibble
cb_summary_stats_few_cats <- function(df, .x, digits = 2) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  var = n = cum_freq = percent = NULL

  # ===========================================================================
  # Variable management
  # ===========================================================================
  x <- rlang::sym(.x)

  # ===========================================================================
  # Calculate measures of interest
  # ===========================================================================
  summary <- df %>%
    dplyr::group_by(!!x) %>%
    bfuncs::freq_table(digits = digits) %>%
    dplyr::mutate(cat = tidyr::replace_na(cat, "Missing")) %>%
    # Change overall total to cumulative total
    dplyr::mutate(cum_freq = cumsum(n)) %>%
    dplyr::select(cat, n, percent, cum_freq) %>%

    # Format numeric results
    dplyr::mutate_all(format, nsmall = digits, big.mark = ",")

  # ===========================================================================
  # Return tibble of results
  # ===========================================================================
  summary
}
