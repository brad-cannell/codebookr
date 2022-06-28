#' Automate creation of a data codebook
#'
#' The codebook function assists with the creation of a codebook for a given
#' data frame.
#'
#' Codebook expects that `df ` is a data frame that you have read into memory
#' from a saved data file. Please provide the path to the saved data file. This
#' function gets selected attributes about file saved at `path` and stores
#' those attributes in a data frame, which is later turned into a flextable and
#' added to the codebook document.
#'
#' @param df The data frame the codebook will describe
#' @param title An optional title that will appear at the top of the Word codebook document
#' @param subtitle An optional subtitle that will appear at the top of the Word codebook document
#' @param description An optional text description of the dataset that will appear on the first page of the Word codebook document
#' @param keep_blank_attributes By default, the column attributes table will omit
#'   the Column description, Source information, Column type, and value labels
#'   rows from the column attributes table in the codebook document if those
#'   attributes haven't been set. In other words, it won't show blank rows for
#'   those attributes. Passing `TRUE` to the keep_blank_attributes argument
#'   will cause the opposite to happen. The column attributes table will include
#'   a Column description, Source information, Column type, and value labels
#'   row for every column in the data frame - even if they don't have a value.
#'
#' @return An rdocx object that can be printed to a Word document
#' @importFrom dplyr %>%
#' @export
#'
#' @examples
#' study_codebook <- codebook(
#'   df = study,
#'   title = "My Example Study",
#'   subtitle = "A Subtitle for My Example Study Codebook",
#'   description = "Brief (or long) description of the data."
#' )
#'
#' \dontrun{
#'
#' # Create the Word codebook document
#' print(study_codebook, path = "study_codebook.docx")
#' }
codebook <- function(df, title = NA, subtitle = NA, description = NA, keep_blank_attributes = FALSE) {

  # ===========================================================================
  # Checks
  # ===========================================================================
  # Check to make sure df is a data frame
  if ( !("data.frame" %in% class(df)) ) {
    stop("Expecting df to be of class data.frame. Instead it was ", class(df))
  }

  # Check to make sure the user is not piping in the data frame
  # When they do, `Dataset name:` in the metadata table (below) is ".".
  # Apparently, there is no way around this:
  # https://stackoverflow.com/questions/30057278/get-lhs-object-name-when-piping-with-dplyr
  df_name <- deparse(substitute(df))
  if (df_name == ".") {
    message(
      "The codebook function currently sees the name of the data frame you ",
      "passed to the `df` argument as '.'. This is probably because you used ",
      "a pipe to pass the data frame name into the codebook function. If you ",
      "want the actual name of the data frame to be printed in the `Dataset ",
      "name:` row of the metadata table, do not use a pipe to pass the data ",
      "frame name into the codebook function."
    )
  }

  # ===========================================================================
  # Create an empty Word rdocx object
  # ===========================================================================
  rdocx <- officer::read_docx() %>%
    officer::cursor_begin()

  # ===========================================================================
  # Optionally add title and subtitle to top of codebook
  # ===========================================================================
  cb_shell <- cb_add_title(
    rdocx = rdocx,
    title = title,
    subtitle = subtitle
  )

  # ===========================================================================
  # Add metadata to codebook shell
  # ===========================================================================
  # Create tibble of metadata
  meta <- tibble::tibble(
    `Dataset name:` = df_name,
    `Dataset size:` = df %>% utils::object.size() %>% format(units = "auto"),
    `Column count:` = df %>% ncol() %>% format(big.mark = ","),
    `Row count:`    = df %>% nrow() %>% format(big.mark = ","),
    `Updated date:` = Sys.Date()
  )

  # Pivot the metadata to a vertical orientation
  # Must covert all values to character to pivot them into the same column
  meta <- meta %>%
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) %>%
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "key",
      values_to = "value"
    )

  # Convert to flextable
  meta <- meta %>%
    flextable::regulartable() %>%
    cb_theme_df_attributes() # Format

  # Add metadata to codebook
  rdocx <- rdocx %>%
    flextable::body_add_flextable(meta)

  # ===========================================================================
  # Optionally Add dataset description
  # ===========================================================================
  if (!is.na(description)) {
    # Add Description header
    rdocx <- rdocx %>%
      cb_add_section_header("Description:")

    # Add dataset description to codebook
    rdocx <- rdocx %>%
      cb_add_description(description)
  }

  # ===========================================================================
  # Iterate over every column in df - control with dplyr::select
  # Add column attributes and summary statistics to rdocx object
  # ===========================================================================

  # Add column Attributes header
  rdocx <- rdocx %>%
    cb_add_section_header("Column Attributes:")

  # Create vector of column names
  col_nms <- names(df)

  # Iterate over all columns
  # ------------------------
  for (i in seq_along(col_nms)) {

    # Get column attributes
    table_var_attributes <- df %>%
      cb_get_col_attributes(col_nms[[i]], keep_blank_attributes = keep_blank_attributes) %>%
      flextable::regulartable() %>%
      cb_theme_col_attr()

    # Add two blank lines above the attributes table
    rdocx <- rdocx %>%
      officer::body_add_par("") %>%
      officer::body_add_par("")

    # Add column attributes flextable to the rdocx object
    rdocx <- rdocx %>%
      flextable::body_add_flextable(table_var_attributes)

    # Get summary statistics
    summary_stats <- df %>%
      cb_add_summary_stats(col_nms[[i]]) %>%
      cb_summary_stats_to_ft()

    # Add summary statistics flextable to the codebook object
    rdocx <- rdocx %>%
      flextable::body_add_flextable(summary_stats)
  }

  # ===========================================================================
  # Return rdocx object that can be printed to a Word document
  # ===========================================================================
  rdocx
}

# For testing
# devtools::load_all()
# print(codebook(study), "test.docx")
