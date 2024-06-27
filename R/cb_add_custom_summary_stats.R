#' Calculate Statistics Based on User Selected Function
#'
#' @description
#' This function is meant to be used within the `codebook` function. It takes a
#' column name character string, a data frame object, a logical value and a
#' character vector as its input arguments in the format:
#' cb_add_custom_summary_stats <- function(.x, df, categorical, custom_funcs).
#' The column name character string is passed from a for loop within the
#' `codebook` function. The purpose of cb_add_summary_stats is to allow the user
#' to customize the statistics shown for a selected list of variables.
#'
#' @param .x Character string of the name of a column of interest.
#' @param categorical A logical value (TRUE or FALSE) that indicates whether the
#' variable of interest should be treated as categorical or numeric while
#' generating the custom summary statistics.
#' @param df The data frame the codebook will describe.
#' @param custom_funcs A character vector of statistics that should be run for
#' the column of interest. There is a list of predefined statistics that the
#' `cb_add_custom_summary_stats` function recognizes:
#' \enumerate{
#'   \item min - for numeric variables.
#'   \item mean - for numeric variables.
#'   \item median - for numeric variables.
#'   \item max - for numeric variables.
#'   \item sd - for numeric variables.
#'   \item n - for categorical variables.
#'   \item cum_freq - for categorical variables.
#'   \item percent - for categorical variables.
#'   }
#' The user may choose one or more statistics from the predefined list or define
#' a custom function that outputs a data frame with a single column and then
#' include its name as a value for the `codebook` function's custom_funcs`
#' argument. Predefined and user-defined statistics can be selected
#' simultaneously only if the output columns have the same length. Therefore,
#' statistics for categorical variables cannot be produced alongside those for
#' numeric variables. For instance, `min` produces a column that has only one
#' row while `cum_freq` produces a column with one row for each category of the
#' variable. These two statistics cannot be generated simultaneously. An attempt
#' will result in an error.
#' @return A tibble of results
#' @family add_summary_stats
#' @keywords internal
#' @importFrom dplyr mutate select group_by summarise rename n case_when reframe

cb_add_custom_summary_stats <- function(.x, df, categorical, custom_funcs){
  # Initialize empty data frame
  summary <- data.frame()

  # List of recognized functions
  rec_funcs <- c("min", "mean", "median", "max", "sd",
                 "n", "cum_freq", "percent")

  for (f in custom_funcs){

    # Generate error message if function is not recognized
    if (!(f %in% rec_funcs)){
      if (exists(f) == FALSE) {
        stop("A value set for custom_funcs is either not among the ",
             "recognized values that include min, mean, median, max, sd, n" ,
             "cum_freq and percent or is not a previously defined function.\n",
             "Check the string input in custom_funcs for typos.")
      }
    }

    # Categorical variables
    if (categorical == TRUE & f %in% rec_funcs){
      if (f == "n"){
        summary_col <- df |>
          # Replace NA with "Missing".
          mutate(
            "{.x}" := as.factor(.data[[.x]]),
            "{.x}" := case_when(
              is.na(.data[[.x]]) == TRUE ~ "Missing",
              TRUE      ~ .data[[.x]]
            )
          ) |>
          select(.data[[.x]]) |>
          group_by(.data[[.x]]) |>
          summarise(
            "{f}" := eval(parse(text = f))()
          ) |>
          rename("Category" = paste0(.x))
      }

      if (f == "cum_freq"){
        summary_col <- df |>
          select(.data[[.x]]) |>
          group_by(.data[[.x]]) |>
          summarise(
            g_frequency = n()
          ) |> ungroup() |>
          mutate(
            cum_freq = cumsum(g_frequency)
          ) |> select(cum_freq)
      }
      if (f == "percent"){
        summary_col <- df |>
          select(.data[[.x]]) |>
          mutate(
            frequency = n()
          ) |>
          group_by(.data[[.x]]) |>
          reframe(
            g_frequency = n(),
            percent = paste0(
              format(
                round((g_frequency/frequency)*100, digits = 2),
                nsmall = 2)
            )
          ) |> unique() |> select(percent)
      }
    }

    # Numeric variables
    if (categorical == FALSE & f %in% rec_funcs){
      summary_col <- df |>
        select(.data[[.x]]) |>
        na.omit() |>
        summarise(
          "{f}" := eval(parse(text = f))(.data[[.x]])
        )
    }

    # Use user defined function
    if (!(f %in% rec_funcs)){
      summary_col <- eval(parse(text = f))(.x)
    }

    # Add product of each function to the summary data frame
    if (f == custom_funcs[1]){
      summary <- rbind(summary, summary_col) # prevent error from using cbind
      # when data frame is empty by using rbind for first function output.
    }
    else{
      summary <- cbind(summary, summary_col)
    }
  }
  summary
}
# # For testing
#
# data(study)
# devtools::load_all()
#
# # User-defined function that takes a data column name as input argument.
# user_defined <- function(.x){
#   sum_col <- study |>
#     select(.data[[.x]]) |>
#     group_by(.data[[.x]]) |>
#     summarise(
#       n = n()
#     ) |> filter(n == max(n)) |>
#     select(-c("n")) |>
#     rename(user_defined = {{.x}})
#   sum_col
# }
# # Create codebook
# test_codebook <- codebook(
#   df = study,
#   title = "Test study",
#   description = "Testing! Testing",
#   custom_stats_cols = c("likert", "days"),
#   categorical = FALSE,
#   custom_funcs = c("min", "mean", "median", "sd", "user_defined"),
#   custom_funcs_labels = c("Minimum", "Mean", "Median", "Std Dev", "User Defined")
# )
#
# print(test_codebook, "test_custom_funcs.docx")
