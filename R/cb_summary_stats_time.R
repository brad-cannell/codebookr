#' Compute Summary Statistics for Date or Time Variables
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param digits Number of digits after decimal to display
#'
#' @return A tibble
#' @family add_summary_stats
#' @importFrom dplyr %>%
cb_summary_stats_time <- function(df, .x, digits = 2) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  Value = Frequency = Percentage = n = Statistic = .data = NULL

  # ===========================================================================
  # Prevents Error in `dplyr::summarise()`:
  # ! Problem while computing `Value = min(...)`.
  # Caused by error in `.data[[<function() .Internal(date())>]]`:
  # ! Must subset the data pronoun with a string, not a function.
  # ===========================================================================
  # .x <- rlang::as_name(rlang::enquo(.x))

  # ===========================================================================
  # Get the minimum value, and the number and percentage of times that value occurs
  # ===========================================================================
  min <- df %>%
    dplyr::summarise(
      Statistic  = "Minimum",
      Value      = min(.data[[.x]], na.rm = TRUE),
      Frequency  = (.data[[.x]] == Value) %>% sum(na.rm = TRUE),
      Percentage = Frequency / nrow(df) * 100
    ) %>%
    # Format output
    dplyr::mutate(
      Frequency  = format(Frequency, big.mark = ","),
      Percentage = round(Percentage, digits = digits),
      Percentage = format(Percentage, nsmal = digits)
    ) %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

  # ===========================================================================
  # Get the mode value(s), and the number and percentage of times that value occurs
  # ===========================================================================
  counts <- df %>%
    dplyr::count(.data[[.x]]) %>%
    dplyr::pull(n)

  # ===========================================================================
  # If all values appear the same number of times, we don't want them all listed out
  # ===========================================================================
  if (length(unique(counts)) == 1) {
    mode <- tibble::tibble(
      Statistic  = "Mode",
      Value      = paste("All", format(length(counts), big.mark = ","), "values"),
      Frequency  = unique(counts),
      Percentage = Frequency / nrow(df) * 100
    ) %>%
      # Format output
      dplyr::mutate(
        Frequency  = format(Frequency, big.mark = ","),
        Percentage = round(Percentage, digits = digits),
        Percentage = format(Percentage, nsmal = digits)
      )%>%
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

  } else {
    mode <- df %>%
      dplyr::count(.data[[.x]], name = "Frequency") %>%
      dplyr::filter(Frequency == max(Frequency)) %>%
      dplyr::mutate(
        Statistic = "Mode",
        Percentage = Frequency / nrow(df) * 100,
        Value = date
      ) %>%
      # Format output
      dplyr::mutate(
        Frequency  = format(Frequency, big.mark = ","),
        Percentage = round(Percentage, digits = digits),
        Percentage = format(Percentage, nsmal = digits)
      ) %>%
      dplyr::select(Statistic, Value, Frequency, Percentage) %>%
      dplyr::mutate(dplyr::across(dplyr::everything(), as.character))
  }

  # ===========================================================================
  # Get the maximum value, and the number and percentage of times that value occurs
  # ===========================================================================
  max <- df %>%
    dplyr::summarise(
      Statistic  = "Maximum",
      Value      = max(.data[[.x]], na.rm = TRUE),
      Frequency  = (.data[[.x]] == Value) %>% sum(na.rm = TRUE),
      Percentage = Frequency / nrow(df) * 100
    ) %>%
    # Format output
    dplyr::mutate(
      Frequency  = format(Frequency, big.mark = ","),
      Percentage = round(Percentage, digits = digits),
      Percentage = format(Percentage, nsmal = digits)
    ) %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character))

  # ===========================================================================
  # Append the stats of interest into a single data frame and return
  # ===========================================================================
  summary <- dplyr::bind_rows(min, mode, max)
  summary
}

# For testing
# data(study)
# cb_summary_stats_time(study, date, digits = 2)
