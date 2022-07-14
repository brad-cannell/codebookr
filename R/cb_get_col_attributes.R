#' Get Column Attributes
#'
#' @description Used in codebook() to create the top half of the column attributes
#' table.
#'
#' @details Typically, though not necessarily, the first step in creating your
#' codebook will be to add column attributes to your data. The
#' `cb_add_col_attributes()` function is a convenience function that allows you
#' to add arbitrary attributes to columns (e.g., description, source, column type).
#' These attributes can later be accessed to fill in the column attributes table
#' of the codebook document. Column attributes _can_ serve a similar function
#' to variable labels in SAS or Stata; however, you can assign many different
#' attributes to a column and they can contain any kind of information you want.
#'
#' Although the `cb_add_col_attributes()` function will allow you to add any
#' attributes you want, there are currently **only four** special attributes
#' that the `codebook()` function (via `cb_get_col_attributes()`) will recognize
#' and add to the column attributes table of the codebook document. They are:
#'
#' * **description**: Although you may add any text you desire to the `description`
#' attribute, it is intended to be used to describe the question/process that
#' generated the data contained in the column. Many statistical software packages
#' refer to this as a variable label.
#'
#' * **source**: Although you may add any text you desire to the `source`
#' attribute, it is intended to be used to describe where the data contained in
#' the column originally came from. For example, if the current data frame was
#' created by merging multiple data sets together, you may want to use the
#' source attribute to identify the data set it originates from. As another
#' example, if the current data frame contains longitudinal data, you may want
#' to use the source attribute to identify the wave(s) in which data for this
#' column was collected.
#'
#' * **col_type**: Although you may add any text you desire to the `col_type`
#' attribute, it is intended to be used to provide additional information above
#' and beyond the `Data type` (i.e., column class) about the values in the
#' column. For example, you may have a column of 0's and 1's, which will have
#' a _numeric_ data type. However, you may want to inform data users that this
#' is really a dummy variable where the 0's and 1's represent discrete
#' categories (No and Yes). Another way to think about it is that the
#' `Data type` attribute is how _R_ understands the column and the `Column type`
#' attribute is how _humans_ should understand the column.
#'
#'    - Perhaps even more importantly, setting the `col_type` attribute helps R
#'  determine which descriptive statistics to calculate for the bottom half of
#'  the column attributes table. Inside of the `codebook()` function, the
#'  `cb_add_summary_stats()` function will attempt to figure out whether the
#'  column is **numeric**, **categorical - many categories (e.g. participant id)**,
#'  **categorical - few categories (e.g. sex)**, or **time - including dates**.
#'  Again, this matters because the table of summary stats shown in the codebook
#'  document depends on the value `cb_add_summary_stats()` chooses. However, the
#'  user can directly tell `cb_add_summary_stats()` which summary stats to
#'  calculate by providing by adding a `col_type` attribute to a column with
#'  one of the following values: `Numeric`, `Categorical`, or `Time`.
#'
#' * **value_labels**: Although you may add any text you desire to the `value_labels`
#' attribute, it is intended to inform your data users about how to correctly
#' interpret numerically coded categorical variables. For example, you may have
#' a column of 0's and 1's that represent discrete categories (i.e., "No" and
#' "Yes") instead of numerical quantities. In some many other software packages
#' (e.g., SAS, Stata, and SPSS), you can layer "No" and "Yes" labels on top of
#' the 0's and 1's to improve the readability of your analysis output. These
#' are commonly referred to as _value labels_. The R programming language does
#' not really have value labels in the same way that other popular statistical
#' software applications do. R users can (and typically should) coerce
#' numerically coded categorical variables into
#' [factors](https://www.r4epi.com/numerical-descriptions-of-categorical-variables.html#factor-vectors);
#' however, coercing to a factor is not the same as adding value labels to a
#' numeric vector because the underlying numeric values can change in the
#' process of creating the factor. For this, and other reasons, many R
#' programmers choose to create a _new_ factor version of a numerically encoded
#' variable as opposed to overwriting/transforming the numerically encoded
#' variable. In those cases, you may want to inform your data users about how
#' to correctly interpret numerically coded categorical variables. Adding value
#' labels to your codebook is one way of doing so.
#'
#' @param df Data frame of interest
#' @param .x Column of interest in df
#' @param keep_blank_attributes By default, the column attributes table will omit
#'   the Column description, Source information, Column type, and value labels
#'   rows from the column attributes table in the codebook document if those
#'   attributes haven't been set. In other words, it won't show blank rows for
#'   those attributes. Passing `TRUE` to the keep_blank_attributes argument
#'   will cause the opposite to happen. The column attributes table will include
#'   a Column description, Source information, Column type, and value labels
#'   row for every column in the data frame - even if they don't have a value.
#'
#' @return A tibble of column attributes
#' @importFrom dplyr %>%
#' @keywords internal
cb_get_col_attributes <- function(df, .x, keep_blank_attributes = keep_blank_attributes) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  value = Attribute = NULL

  # ===========================================================================
  # Variable management
  # ===========================================================================
  x <- rlang::sym(.x)

  # ===========================================================================
  # Using Haven labels
  # When we import data from Stata, SAS, or SPSS with labels, the attributes
  # are called $label for variable labels and $labels for value labels.
  # Currently, codebook() cannot automatically make use of those attributes
  # because it only recognizes the attributes description, source, and col_type.
  # It's relatively easy to manually set the value of the description attribute
  # to the value of the label attribute. However, because Haven labeled data is
  # so common, we decided to specifically look for $label and $labels here.
  # ===========================================================================

  # Label vs. Description
  # ---------------------
  # See issue #12. If both "label" and "description" exist, then "description"
  # should win. The idea is that if I have taken the time to manually type out
  # a description, it should win out over whatever happened to be in label.
  # If there is no description attribute, but there is a label attribute, then
  # "description" should be set to "label".
  description <- attributes(df[[.x]])[["description"]]
  if (is.null(description)) {
    description <- attr(df[[.x]], "label")
  }

  # Value labels
  #-------------
  # First, test to see if there is a `value_labels` or `labels` attribute.
  # If not, move on.
  if (!is.null(attr(df[[.x]], "value_labels")) || !is.null(attr(df[[.x]], "labels"))) {
    # By default, labels are a named vector. For example:
    # $labels
    # Female   Male
    #      1      2
    # value_labels should also be a named vector or list.
    # First, see if there are user defined value labels, if not add haven labels.
    # User defined win if both exist.
    value_labels <- attr(df[[.x]], "value_labels")
    if (is.null(value_labels)) {
      value_labels <- attr(df[[.x]], "labels")
    }
    # Next, check to make sure value_labels is a named vector/list with no missing
    # name values
    # Check to make sure labels or value_labels is a vector or list
    if (!is.vector(value_labels)) {
      stop(
        "Codebook expects value_labels to contain a named vector (or list). ",
        .x, " has a class of ", paste0(class(value_labels), sep = " ")
      )
    }
    # Make sure the vector/list is named with no missing names
    val_nms <- names(value_labels)
    if (is.null(val_nms) || any(val_nms == "")) {
      stop(
        "Codebook expects value_labels to contain a named vector (or list) ",
        "without any missing name values. The name values for ", .x, " are: ",
        paste0(val_nms, sep = " "), ". If there aren't any values listed, ",
        "it may be because all of the names are blank/missing."
      )
    }
    # Without some manipulation, only the values (i.e., 1 and 2) will end up in
    # the column attributes table. We need to convert the values and value labels
    # into a more human readable format.
    value_labels <- paste(value_labels, val_nms, sep = " = ")
  } else {
    value_labels <- NULL
  }

  # ===========================================================================
  # Create attributes data frame - will be converted to flextable
  # ===========================================================================
  data_type <- class(df[[.x]]) %>%
    # Some columns have more than one class (e.g., study$time). That causes
    # two rows to appear in the column attribute table. The paste code fixes
    # the problem
    paste(collapse = ", ")
  data_type <- stringr::str_replace(
    data_type,
    stringr::str_extract(data_type, "^\\w{1}"),
    toupper(stringr::str_extract(data_type, "^\\w{1}"))
  )

  # Issue 13. Keep blank rows in the column attributes table if
  # keep_blank_attributes = TRUE
  if (keep_blank_attributes == TRUE) {
    if (is.null(description)) description <- ""
    if (is.null(attr(df[[.x]], "source"))) attr(df[[.x]], "source") <- ""
    if (is.null(attr(df[[.x]], "col_type"))) attr(df[[.x]], "col_type") <- ""
    if (is.null(value_labels)) value_labels <- ""
    if (is.null(attr(df[[.x]], "skip_pattern"))) attr(df[[.x]], "skip_pattern") <- ""
  }

  attr_df <- df %>%
    dplyr::summarise(
      `Column name:`                    = .x,
      `Column description:`             = description,
      `Source information:`             = attributes(df[[.x]])[["source"]],
      `Column type:`                    = attributes(df[[.x]])[["col_type"]],
      `Data type:`                      = data_type,
      `Unique non-missing value count:` = unique(!!x) %>% stats::na.exclude() %>% length(),
      `Missing value count:`            = is.na(!!x) %>% sum(),
      `Value labels:`                   = value_labels,
      `Skip pattern:`                   = attributes(df[[.x]])[["skip_pattern"]]
    ) %>%
    # Format output
    dplyr::mutate_if(is.numeric, format, big.mark = ",") %>%
    tidyr::gather(key = "Attribute")

  # ===========================================================================
  # Delete duplicate attribute rows
  # When there is more than one value label, the only way to get each value
  # label to appear on a separate line of the column attributes table (the most
  # readable output for humans) is to create a separate row in the data frame
  # for each value label. However, R's recycling rules then automatically
  # create the same number of rows for every other attribute. The  code below
  # cleans that up.
  # ===========================================================================
  # Keep one row for each unique combination of `Attribute` and `value`
  attr_df <- dplyr::distinct(attr_df)
  # Keep only the first instance of `Attribute`.
  # This is so that "Value labels:" is only printed once as opposed to once for
  # each value label.
  attr_df <- attr_df %>%
    dplyr::group_by(Attribute) %>%
    dplyr::mutate(Attribute = dplyr::if_else(dplyr::row_number() == 1, Attribute, ""))

  # ===========================================================================
  # Return data frame
  # ===========================================================================
  attr_df
}

# For testing
# devtools::load_all()
# cb_get_col_attributes(study, "likert", keep_blank_attributes = FALSE)
