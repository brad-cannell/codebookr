#' Get Column Attributes
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
  # Setting attributes to NA if not set by user
  # ===========================================================================
  attribs <- c("description", "source", "col_type")
  for (i in seq_along(attribs)) {
    if (is.null(attributes(df[[.x]])[[attribs[i]]])) {
      attr(df[[.x]], attribs[i]) <- NA
    }
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
      `Missing value count:`            = is.na(!!x) %>% sum()
    ) %>%
    # Format output
    dplyr::mutate_if(is.numeric, format, big.mark = ",") %>%
    tidyr::gather(key = "Attribute")

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
