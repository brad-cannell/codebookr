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
#' @importFrom dplyr %>%
cb_add_summary_stats <- function(df,
                                 .x,
                                 many_cats = 10,
                                 num_to_cat = 4,
                                 digits = 2,
                                 n_extreme_cats = 5) {

  # ===========================================================================
  # Variable management
  # ===========================================================================
  x <- rlang::enquo(.x)
  x_char <- rlang::as_name(.x)
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

  # Try to guess col_type if col_type wasn't set by the user.
  # The guess is made from a combination of the columns class and the number
  # of unique non-missing values it has -- compared to the value of many_cats
  # (logical, character, factor) or the value of num_to_cat (numeric).
  # The user can avoid the guessing algorithm by explicitly set the col_type
  # attribute
  if (col_type == "guess") {

    # Get class
    x_class <- class(df[[.x]])
    x_class

    # Logical, character, and factor are categorical
    if ("logical" %in% x_class) {
      # Logical can only take three values (T/F/NA), so it should always be
      # few_cats.
      # Theoretically, someone could set many_cats to 1 and this
      # would return unexpected results (few_cats instead of many_cats),
      # but that seems unlikely in practice.
      col_type <- "few_cats"
    } else if ("character" %in% x_class || "factor" %in% x_class) {
      # For character and factor, figure out if they have many categories
      # or few categories (compared to the value of many_cats)
      if (n_unique_vals >=  many_cats) {
        col_type <- "many_cats"
      } else {
        col_type <- "few_cats"
      }
    } else if ("integer" %in% x_class || "numeric" %in% x_class) {
      # Integer and numeric may be numeric or categorical (e.g. likert)
      # Use num_to_cat as a cut-off value for determining if a numeric variable
      # is really categorical
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
    } else if ("Date" %in% x_class || "POSIXct" %in% x_class ||
               "POSIXt" %in% x_class || "hms" %in% x_class ||
               "difftime" %in% x_class) {
      # If it is one of these common date/time classes, then set col_type to
      # time. If it is some other date/time class, the user can always manually
      # set the col_type attribute equal to "time".
      col_type <- "time"
    } else {
      stop("Column ", .x, " is of unknown type. Please set the col_type attribute")
    }
  }

  # ===========================================================================
  # Create attributes data frame - will be converted to flextable
  # ===========================================================================
  if (col_type == "numeric") {
    summary_df <- cb_summary_stats_numeric(df, .x)
    class(summary_df) <- c("summary_numeric", class(summary_df))
  } else if (col_type == "many_cats") {
    summary_df <- cb_summary_stats_many_cats(df, .x, n_extreme_cats)
    class(summary_df) <- c("summary_many_cats", class(summary_df))
  } else if (col_type == "few_cats") {
    summary_df <- cb_summary_stats_few_cats(df, .x, digits)
    class(summary_df) <- c("summary_few_cats", class(summary_df))
  } else if (col_type == "time") {
    summary_df <- cb_summary_stats_time(df, .x)
    class(summary_df) <- c("summary_time", class(summary_df))
  } else {
    stop("Column ", .x, " is of unknown type. Please set the col_type attribute")
  }

  # ===========================================================================
  # Return data frame
  # ===========================================================================
  summary_df
}

# For testing
# Currently, the codebook function passes df to the df argument of cb_add_summary_stats
# and a character string (e.g., "id") for each column in df to the .x argument
# of cb_add_summary_stats
# cb_add_summary_stats(study, "id")
