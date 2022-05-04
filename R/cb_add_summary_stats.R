#' Calculate Appropriate Statistics for Variable Type
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param many_cats Set cutoff value for many categories/few categories
#' @param num_to_cat Set cutoff value for guessing that a numeric variable is actually categorical
#' @param digits Number of digits after decimal to display
#' @param n_extreme_cats Number of extreme values to display
#'
#' @return A tibble of results
codebook_add_summary_stats <- function(df, .x, many_cats = 10, num_to_cat = 4, digits = 2,
                                       n_extreme_cats = 5) {

  # ===========================================================================
  # Variable management
  # ===========================================================================
  # x <- rlang::enquo(.x)
  # x_char <- rlang::quo_name(x)
  attrs <- attributes(df[[.x]])
  col_type_attr <- tolower(attrs[["col_type"]])

  # ===========================================================================
  # Determine type of variable:
  # Numerical
  # Categorical - many categories (e.g. participant id)
  # Categorical - few categories (e.g. gender)
  # ===========================================================================
  # Check the number of unique non-missing values
  n_unique_vals <- unique(df[[.x]]) %>% stats::na.exclude() %>% length()

  # Check for defined col_type
  if (length(col_type_attr) == 0) {
    col_type <- "guess"
  } else if (col_type_attr %in% c("numeric", "numerical")) {
    col_type <- "numeric"
  } else if (col_type_attr == "categorical" && n_unique_vals >=  many_cats) {
    col_type <- "many_cats"
  } else if (col_type_attr == "categorical" && n_unique_vals < many_cats) {
    col_type <- "few_cats"
  } else if (col_type_attr == "time") {
    col_type <- "time"
  } else {
    col_type <- "guess"
  }

  # Try to guess col_type where needed
  # If the user doesn't like these guesses, they can always go back and
  # explicitly set the col_type attribute
  if (col_type == "guess") {

    # Get class
    x_class <- class(df[[.x]])
    x_class

    # Try to guess from class
    # Logical, character, and factor are categorical
    if (x_class %in% c("logical", "character", "factor")){
      # Figure out if they have many categories or few categories
      if (n_unique_vals >=  many_cats) {
        col_type <- "many_cats"
      } else {
        col_type <- "few_cats"
      }
      # Integer and numeric may be numeric or categorical
      # Use num_to_cat as a cut-off value for determining if a numeric variable
      # is really categorical
    } else if (x_class %in% c("integer", "numeric")) {
      # If n_unique_vals is <= num_to_cat then we guess categorical
      if (n_unique_vals <= num_to_cat) {
        # If guessed categorical, then determine if many cats or few cats
        if (n_unique_vals >=  many_cats) {
          col_type <- "many_cats"
        } else {
          col_type <- "few_cats"
        }
        # If n_unique_vals is > num_to_cat then we guess numeric
      } else {
        col_type <- "numeric"
      }
    } else if (x_class %in% c("Date", "POSIXct", "POSIXt")) {
      col_type <- "time"
    } else {
      stop("Column ", .x, " is of unknown type. Please set the col_type attribute")
    }
  }

  # ===========================================================================
  # Create attributes data frame - will be converted to flextable
  # ===========================================================================
  if (col_type == "numeric") {
    summary_df <- codebook_summary_stats_numeric(df, .x)
    class(summary_df) <- c(class(summary_df), "summary_numeric")
  } else if (col_type == "many_cats") {
    summary_df <- codebook_summary_stats_many_cats(df, .x, n_extreme_cats)
    class(summary_df) <- c(class(summary_df), "summary_many_cats")
  } else if (col_type == "few_cats") {
    summary_df <- codebook_summary_stats_few_cats(df, .x, digits)
    class(summary_df) <- c(class(summary_df), "summary_few_cats")
  } else if (col_type == "time") {
    summary_df <- codebook_summary_stats_time(df, .x)
    class(summary_df) <- c(class(summary_df), "summary_time")
  } else {
    stop("Column ", .x, " is of unknown type. Please set the col_type attribute")
  }

  # ===========================================================================
  # Return data frame
  # ===========================================================================
  summary_df
}
