#' Calculate Appropriate Statistics for Variable Type
#'
#' @description
#' The input to cb_add_summary_stats is a data frame and a column from that
#' data frame in the format cb_add_summary_stats(study, "id"). The column name
#' is a character string because it is passed from a for loop in the `codebook`
#' function. The purpose of cb_add_summary_stats is to attempt to figure out
#' whether the column is:
#' \enumerate{
#'   \item Numeric (e.g., height)
#'   \item Categorical - many categories (e.g. participant id)
#'   \item Categorical - few categories (e.g. gender)
#'   \item Time - including dates
#' }
#' This matters because the table of summary stats shown in the codebook
#' document depends on the value cb_add_summary_stats chooses.
#'
#' @details
#' The user can tell the cb_add_summary_stats function what to choose explicitly
#' by giving the column a col_type attribute set to one of the following values:
#' \enumerate{
#'   \item Numeric. For example, height and/or weight.
#'   \itemize{
#'     \item `study <- cb_add_col_attributes(study, height, col_type = "numeric")`
#'   }
#'   \item Categorical. We describe how many categories vs few categories is
#'   determined below.
#'   \itemize{
#'     \item `study <- cb_add_col_attributes(study, id, col_type = "categorical")`
#'   }
#'   \item Time. Dates, times, and datetimes.
#'   \itemize{
#'     \item `cb_add_col_attributes(study, date, col_type = "time")`
#'   }
#' }
#'
#' If the user does not explicitly set the col_type attribute to one of these
#' values, then cb_add_summary_stats will guess which col_type attribute to
#' assign to each column based on the column's class and the number of unique
#' non-missing values the it has.
#'
#' However, the number of unique non-missing values isn't used in an absolute
#' way (e.g., 10 or more unique values is ALWAYS many_cats). Instead, the number
#' of unique non-missing values used relative to the values passed to the
#' many_cats parameter and/or the num_to_cat parameter -- depending on the class
#' of the column.
#'
#' @param df Data frame of interest
#' @param .x Column of interest
#' @param many_cats The many_cats argument sets the cutoff value that partially
#'   (i.e., along with the col_type attribute) determines whether
#'   cb_add_summary_stats will categorize the variable as categorical with few
#'   categories or categorical with many categories. The number of categories
#'   that constitutes "many" is defined by the value passed to the many_cats
#'   argument. The default is 10.
#' @param num_to_cat The num_to_cat argument sets the cutoff value that partially
#'   (i.e., along with the col_type attribute) determines whether
#'   cb_add_summary_stats will categorize a numeric as categorical. If the
#'   col_type attribute is not set for a column AND the number of unique
#'   non-missing values is <= num_to_cat, then cb_add_summary_stats will guess
#'   that the variable is categorical. The default value for num_to_cat is 4.
#' @param digits Number of digits after the decimal to display
#' @param n_extreme_cats Number of extreme values to display when the column is
#'   classified as `many_cats`. By default, the 5 least frequently occurring
#'   values and the 5 most frequently occurring values are displayed.
#'
#' @return A tibble of results
#' @family add_summary_stats
#' @importFrom dplyr %>%
#' @keywords internal
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
  # Time - including dates
  # ===========================================================================
  # Check the number of unique non-missing values
  n_unique_vals <- unique(df[[.x]]) %>% stats::na.exclude() %>% length()

  # Check for user-set col_type
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

    # haven_labeled
    # When you import data from SAS, Stata, or SPSS using Haven, it adds two
    # classes to variables with value labels:  `haven_labelled` and `vctrs_vctr`.
    # Passing these columns to `codebook()` results in an error.
    # One way to get around this is simply to set the `col_type` attribute.
    # However, because Haven labeled data is so common, we decided to specifically
    # look for and remove those classes in this section of code that is trying to
    # determine the column type. It should not remove those class from the column
    # generally.
    x_class <- x_class[!x_class %in% c("haven_labelled", "vctrs_vctr")]
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
    } else if ("integer" %in% x_class || "double" %in% x_class || "numeric" %in% x_class) {
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
# devtools::load_all()
# codebookr:::cb_add_summary_stats(study, "sex")
