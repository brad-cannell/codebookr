#' Compute Summary Statistics for Categorical Variables with Few Categories
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param digits Number of digits after decimal to display
#'
#' @return A tibble
#' @family add_summary_stats
#' @importFrom dplyr %>%
cb_summary_stats_few_cats <- function(df, .x, digits = 2) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  var = n = cum_freq = prop = percent = .data = NULL

  # ===========================================================================
  # Calculate measures of interest
  # ===========================================================================
  summary <- df %>%
    dplyr::count(.data[[.x]]) %>%
    # Rename the first column from the name of the variable being analyzed to
    # "cat"
    dplyr::rename(cat = 1) %>%
    # Change the category label for missing values from NA to "Missing"
    # If .x is a factor, then replace_na() won't work. Have to change to
    # character first.
    dplyr::mutate(
      cat = as.character(cat),
      cat = tidyr::replace_na(cat, "Missing")
    ) %>%
    # Calculate the cumulative total and percentage
    dplyr::mutate(
      cum_freq = cumsum(n),
      prop     = n / max(cum_freq),
      percent  = prop * 100
    ) %>%
    # Keep columns of interest
    dplyr::select(cat, n, cum_freq, percent) %>%
    # Format numeric results
    dplyr::mutate(
      dplyr::across(
        .cols = c(n, cum_freq, percent),
        .fns  = ~ format(.x, nsmall = digits, big.mark = ",")
      )
    )

  # ===========================================================================
  # Return tibble of results
  # ===========================================================================
  summary
}

# For testing
# data(study)
# cb_summary_stats_few_cats(study, sex, digits = 2)
