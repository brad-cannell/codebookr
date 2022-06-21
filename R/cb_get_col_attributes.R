#' Get Column Attributes
#'
#' @description Used in codebook() to create the top half of the column attributes
#' table.
#'
#' @param df Data frame of interest
#' @param .x Column of interest in df
#'
#' @return A tibble
#' @importFrom dplyr %>%
cb_get_col_attributes <- function(df, .x) {

  # ===========================================================================
  # Prevents R CMD check: "no visible binding for global variable ‘.’"
  # ===========================================================================
  value = NULL

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













