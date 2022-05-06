#' Compute Summary Statistics for Categorical Variables with Many Categories
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param n_extreme_cats Number of extreme values to display
#'
#' @return A tibble
#' @importFrom dplyr %>%
cb_summary_stats_many_cats <- function(df, .x, n_extreme_cats = 5) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  n = head = tail = lowest_cats = highest_cats = NULL

  # ===========================================================================
  # Create table shell
  # ===========================================================================
  summary <- tibble::tibble(
    lowest_cats  = rep(NA, n_extreme_cats),
    lowest_freq  = rep(NA, n_extreme_cats),
    highest_cats = rep(NA, n_extreme_cats),
    highest_freq = rep(NA, n_extreme_cats)
  )

  # ===========================================================================
  # Get least prevalent categories
  # ===========================================================================
  lowest <- df %>%
    dplyr::count({{ .x }}) %>%
    dplyr::arrange(n) %>%
    head(n = n_extreme_cats)

  # ===========================================================================
  # Get most prevalent categories
  # ===========================================================================
  highest <- df %>%
    dplyr::count({{ .x }}) %>%
    dplyr::arrange(n) %>%
    tail(n = n_extreme_cats)

  # ===========================================================================
  # Fill-in and return table shell
  # ===========================================================================
  summary[, 1:2] <- lowest[, 1:2]
  summary[, 3:4] <- highest[, 1:2]
  summary <- summary %>%
    # Change the category label for missing values from NA to "Missing"
    # If .x is a factor, then replace_na() won't work. Have to change to
    # character first.
    dplyr::mutate(
      lowest_cats  = as.character(lowest_cats),
      lowest_cats  = tidyr::replace_na(lowest_cats, "Missing"),
      highest_cats = as.character(highest_cats),
      highest_cats = tidyr::replace_na(highest_cats, "Missing")
    )
  summary
}

# For testing
# data(study)
# cb_summary_stats_many_cats(study, id)
