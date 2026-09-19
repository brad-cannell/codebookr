#' Compute Summary Statistics for Categorical Variables with Few Categories
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param digits Number of digits after decimal to display
#'
#' @return A tibble
#' @family add_summary_stats
#' @importFrom dplyr %>%
#' @keywords internal
cb_summary_stats_few_cats <- function(df, .x, digits = 2) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable '.'"
  # ===========================================================================
  var = n = cum_freq = prop = percent = is_missing = valid_n = valid_percent = .data = NULL

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
      cat        = as.character(cat),
      is_missing = is.na(cat),
      cat        = tidyr::replace_na(cat, "Missing")
    ) %>%
    # Calculate the cumulative total, the percent of all observations, and
    # the percent among non-missing (valid) observations only
    dplyr::mutate(
      cum_freq      = cumsum(n),
      prop          = n / max(cum_freq),
      percent       = round(prop * 100, digits),
      valid_n       = sum(n[!is_missing]),
      valid_percent = dplyr::if_else(
        is_missing, NA_real_, round(n / valid_n * 100, digits)
      )
    ) %>%
    # Keep columns of interest
    dplyr::select(cat, n, cum_freq, percent, valid_percent) %>%
    # Format numeric results
    dplyr::mutate(
      dplyr::across(
        .cols = c(n, cum_freq, percent),
        .fns  = ~ format(.x, nsmall = digits, big.mark = ",")
      ),
      # Missing rows have no valid_percent (there's no "valid" denominator
      # they belong to) — display "--" instead of NA
      valid_percent = dplyr::if_else(
        is.na(valid_percent),
        "--",
        format(valid_percent, nsmall = digits, big.mark = ",")
      )
    )

  # ===========================================================================
  # Return tibble of results
  # ===========================================================================
  summary
}

# For testing
# data(study)
# cb_summary_stats_few_cats(study, "sex", digits = 2)
