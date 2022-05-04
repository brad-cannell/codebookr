#' Compute Summary Statistics for Date Variables
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param digits Number of digits after decimal to display
#'
#' @return A tibble
#' @importFrom dplyr %>%
cb_summary_stats_time <- function(df, .x, digits = 2) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  Value = Frequency = Percentage = n = Statistic = NULL

  # ===========================================================================
  # Variable management
  # ===========================================================================
  x <- rlang::sym(.x)
  x_char <- rlang::quo_name(x)

  # ===========================================================================
  # Get the minimum value, and the number and percentage of times that value occurs
  # ===========================================================================
  min <- df %>%
    dplyr::summarise(
      Statistic  = "Minimum",
      Value      = min(df[[x_char]], na.rm = TRUE),
      Frequency  = (df[[x_char]] == Value) %>% sum(),
      Percentage = Frequency / nrow(df) * 100
    ) %>%
    # Format output
    dplyr::mutate(
      Frequency  = format(Frequency, big.mark = ","),
      Percentage = round(Percentage, digits = digits),
      Percentage = format(Percentage, nsmal = digits)
    ) %>%
    dplyr::mutate_all(as.character)

  # ===========================================================================
  # Get the mode value(s), and the number and percentage of times that value occurs
  # ===========================================================================
  counts <- df %>%
    dplyr::group_by(!!x) %>%
    dplyr::summarise(n = n()) %>%
    dplyr::pull(n)

  # ===========================================================================
  # If all values appear the same number of times, we don't want them all listed out
  # ===========================================================================
  if (length(unique(counts)) == 1) {
    mode <- tibble::tibble(
      Statistic  = "Mode",
      Value      = paste("All ", format(length(counts), big.mark = ","), "values"),
      Frequency  = unique(counts),
      Percentage = Frequency / nrow(df) * 100
    ) %>%
      # Format output
      dplyr::mutate(
        Frequency  = format(Frequency, big.mark = ","),
        Percentage = round(Percentage, digits = digits),
        Percentage = format(Percentage, nsmal = digits)
      )%>%
      dplyr::mutate_all(as.character)

  } else {
    mode <- df %>%
      dplyr::group_by(!!x) %>%
      dplyr::summarise(Frequency = n()) %>%
      dplyr::filter(Frequency == max(Frequency)) %>%
      dplyr::mutate(
        Statistic = "Mode",
        Percentage = Frequency / nrow(df) * 100,
        Value = !!x
      ) %>%
      # Format output
      dplyr::mutate(
        Frequency  = format(Frequency, big.mark = ","),
        Percentage = round(Percentage, digits = digits),
        Percentage = format(Percentage, nsmal = digits)
      ) %>%
      dplyr::select(Statistic, Value, Frequency, Percentage) %>%
      dplyr::mutate_all(as.character)
  }

  # ===========================================================================
  # Get the maximum value, and the number and percentage of times that value occurs
  # ===========================================================================
  max <- df %>%
    dplyr::summarise(
      Statistic  = "Maximum",
      Value      = max(df[[x_char]], na.rm = TRUE),
      Frequency  = (df[[x_char]] == Value) %>% sum(),
      Percentage = Frequency / nrow(df) * 100
    ) %>%
    # Format output
    dplyr::mutate(
      Frequency  = format(Frequency, big.mark = ","),
      Percentage = round(Percentage, digits = digits),
      Percentage = format(Percentage, nsmal = digits)
    ) %>%
    dplyr::mutate_all(as.character)

  # ===========================================================================
  # Append the stats of interest into a single data frame and return
  # ===========================================================================
  summary <- dplyr::bind_rows(min, mode, max)
  summary
}
