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
#' * **val_labels**: Although you may add any text you desire to the `val_labels`
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
#'
#' @return A tibble of column attributes
#' @importFrom dplyr %>%
cb_get_col_attributes <- function(df, .x) {

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

  # Set description to label if label exists
  attr(df[[.x]], "description") <- attr(df[[.x]], "label")

  # Set val_labels to labels if labels exists
  # By default, labels are a named vector. For example:
  # $labels
  # Female   Male
  #      1      2
  # Without some manipulation, only the values (i.e., 1 and 2) will end up in
  # the column attributes table. We need to convert the values and value labels
  # into a more human readable format.
  val_labels <- attr(df[[.x]], "labels")
  if (!is.null(val_labels)) {
    val_nms    <- names(val_labels)
    val_labels <- paste(val_labels, val_nms, sep = " = ")
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

  attr_df <- df %>%
    dplyr::summarise(
      `Column name:`                    = .x,
      `Column description:`             = attributes(df[[.x]])[["description"]],
      `Source information:`             = attributes(df[[.x]])[["source"]],
      `Column type:`                    = attributes(df[[.x]])[["col_type"]],
      `Data type:`                      = data_type,
      `Unique non-missing value count:` = unique(!!x) %>% stats::na.exclude() %>% length(),
      `Missing value count:`            = is.na(!!x) %>% sum(),
      `Value labels:`                   = val_labels
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
  # Delete unused attribute rows
  # ===========================================================================
  attr_df <- attr_df %>%
    dplyr::filter(!is.na(value))

  # ===========================================================================
  # Return data frame
  # ===========================================================================
  attr_df
}


# For testing
# Using the Stata version of study
# devtools::load_all()
# cb_get_col_attributes(study, "id")













