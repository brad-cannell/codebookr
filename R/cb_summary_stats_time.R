#' Compute Summary Statistics for Date or Time Variables
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param digits Number of digits after decimal to display
#'
#' @return A tibble
#' @family add_summary_stats
#' @importFrom dplyr %>%
#' @keywords internal
cb_summary_stats_time <- function(df, .x, digits = 2) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  Value = Frequency = Percentage = n = Statistic = .data = NULL

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
        Value = .data[[.x]]
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

  # ===========================================================================
  # Issue 15: Make time appear in a human readable format
  # If .x is hms, we need to convert it to numeric before calculating min,
  # mode, max. We will then need to convert it back to hms before returning
  # the summary table.
  # ===========================================================================
  if ("hms" %in% class(df[[.x]])) {
    min_hms <- as.character(hms::as_hms(as.numeric(summary$Value[summary$Statistic == "Minimum"])))
    max_hms <- as.character(hms::as_hms(as.numeric(summary$Value[summary$Statistic == "Maximum"])))
    # If there is no mode, the value will be "All X values" and grepl will
    # TRUE
    mode_char <- grepl("All", summary$Value[summary$Statistic == "Mode"])
    # If mode_char is TRUE, then do nothing so that the value for mode will still
    # "All X values"
    if (!mode_char) {
      # Otherwise, convert the number into an hms value
      summary$Value[summary$Statistic == "Mode"] <- as.character(hms::as_hms(summary$Value[summary$Statistic == "Mode"]))
    }
    summary$Value[summary$Statistic == "Minimum"] <- min_hms
    summary$Value[summary$Statistic == "Maximum"] <- max_hms
  }

  # ===========================================================================
  # Return data frame of summary stats
  # ===========================================================================
  summary
}

# For testing
# devtools::load_all()
# data(study)
# study$date_time[2] <- study$date_time[1]
# study$time[2] <- study$time[1]
# cb_summary_stats_time(study, "date_time", digits = 2)
