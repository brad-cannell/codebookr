#' Adjust the codebook function so that it allows for the injection of arbitrary summary tables into the codebook.

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
#' @details Typically, though not necessarily, the first step in creating your
#'   codebook will be to add column attributes to your data. The
#'   `cb_add_col_attributes()` function is a convenience function that allows
#'   you to add arbitrary attributes to the columns of the data frame. These
#'   attributes can later be accessed to fill in the column attributes table of
#'   the codebook document. Column attributes _can_ serve a similar function to
#'   variable labels in SAS or Stata; however, you can assign many different
#'   attributes to a column and they can contain any kind of information you want.
#'   For details see \link{cb_add_col_attributes}
#'
#' @param df The data frame the codebook will describe
#' @param title An optional title that will appear at the top of the Word
#'   codebook document
#' @param subtitle An optional subtitle that will appear at the top of the Word
#'   codebook document
#' @param description An optional text description of the dataset that will
#'   appear on the first page of the Word codebook document
#' @param keep_blank_attributes TRUE or FALSE. By default, the column attributes
#'   table will omit the Column description, Source information, Column type,
#'   value labels, and skip pattern rows from the column attributes table in
#'   the codebook document if those attributes haven't been set. In other
#'   words, it won't show blank rows for those attributes. Passing `TRUE` to
#'   the keep_blank_attributes argument will cause the opposite to happen.
#'   The column attributes table will include a Column description, Source
#'   information, Column type, and value labels row for every column in the
#'   data frame - even if they don't have those attributes set.
#' @param no_summary_stats A character vector of column names. The summary
#'   statistics will not be added to column attributes table for any
#'   column passed to this argument. This can be useful when a column contains
#'   values that are sensitive or may be used to identify individual people
#'   (e.g., names, addresses, etc.) and the individual values for that column
#'   should not appear in the codebook.
#' @param custom_summary_stats_list A list of named data frames with each data
#' frame containing user-prepared summary statistics for a column. Each column
#' that has a corresponding data frame in this list will have a table containing
#' user-prepared statistics in the codebook instead of generated summary
#' statistics.
#' @return An rdocx object that can be printed to a Word document
#' @importFrom dplyr %>%
#' @import haven
#' @export
#'
#' @examples
#' \dontrun{
#' study_codebook <- codebook(
#'   df = study,
#'   title = "My Example Study",
#'   subtitle = "A Subtitle for My Example Study Codebook",
#'   description = "Brief (or long) description of the data."
#' )
#'
#' # Create the Word codebook document
#' print(study_codebook, path = "example_codebook.docx")
#' }
codebook <- function(
    df, title = NA, subtitle = NA, description = NA,
    keep_blank_attributes = FALSE, no_summary_stats = NULL, custom_summary_stats_list = NULL) {

  # Create character vector of column names in custom_summary_stats_list
  custom_summary_stats_cols <- names(custom_summary_stats_list)

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
  rdocx <- cb_add_title(
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
  # Iterate over every column in df
  # Add column attributes and summary statistics to rdocx object
  #
  # Issue 17: Codebook is really slow when the data frame is even moderately
  # large. Upon investigation, it appears as though the time it takes to
  # complete each iteration of the loop below grows almost exponentially with
  # the number of variables. The solution for this problem came from:
  # https://ardata-fr.github.io/officeverse/officer-for-word.html#external-documents
  # It is necessary to generate smaller Word documents and to insert them into
  # the main Word document using .
  # ===========================================================================

  # Add column Attributes header
  rdocx <- rdocx %>%
    cb_add_section_header("Column Attributes:")

  # Create vector of column names
  col_nms <- names(df)

  # External documents approach to speed up the function
  # Create temporary external files. These will be filled with a single
  # Word document for each column. Then, each temporary Word document will be
  # added to the main document
  tmpdir <- tempfile()
  dir.create(tmpdir, showWarnings = FALSE, recursive = TRUE)
  tempfiles <- file.path(tmpdir, paste0(seq_along(col_nms), ".docx") )

  # Iterate over all columns
  # ------------------------
  for (i in seq_along(col_nms)) {

    # Create a temporary rdocx object just for the current column
    temp_doc <- officer::read_docx()

    # Get column attributes
    table_var_attributes <- df %>%
      cb_get_col_attributes(col_nms[[i]], keep_blank_attributes = keep_blank_attributes)
    # Iss 10: Add column number to the column attributes table
    table_var_attributes$Column <- i
    table_var_attributes$Column[-1] <- NA
    table_var_attributes <- table_var_attributes[, c("Column", "Attribute", "value")]
    # Make into a flextable and format
    table_var_attributes <- table_var_attributes %>%
      flextable::flextable() %>%
      cb_theme_col_attr()

    # Add column attributes flextable to the temporary rdocx object
    temp_doc <- temp_doc %>%
      flextable::body_add_flextable(table_var_attributes)

    # Get summary statistics
    # Iss 22. Add option to prevent summary stats table for selected columns
    if (!(col_nms[[i]] %in% no_summary_stats) & !(col_nms[[i]] %in% custom_summary_stats_cols)) {
      summary_stats <- df %>%
        cb_add_summary_stats(col_nms[[i]]) %>%
        cb_summary_stats_to_ft()
    }

    # Use arbitrary summary stats instead of generated summary stats for specified columns
    else if (col_nms[[i]] %in% custom_summary_stats_cols){
      summary_stats <- custom_summary_stats_list[[paste0(col_nms[[i]])]] %>%
        cb_custom_summary_stats_to_ft()
    }
    # Add summary statistics flextable to the codebook object
    temp_doc <- temp_doc %>%
      flextable::body_add_flextable(summary_stats)


    # Create temporary Word document from the temporary rdocx object
    # Put it in one of the temporary files created above the loop.
    print(temp_doc, target = tempfiles[i])
  }

  # tempfiles contains all generated docx paths from the loop. We will
  # iteratively add each of the temporary Word documents to the main
  # rdocx object.
  for (tempfile in tempfiles){
    rdocx <- rdocx %>%
      officer::body_add_docx(src = tempfile)
  }

  # ===========================================================================
  # Return rdocx object that can be printed to a Word document
  # ===========================================================================
  rdocx
}

# For testing


# data(study)
# devtools::load_all()

# # Test named list of data frames
# days <- data.frame(y1 = c(1, 2, 3),
#                    y2 = c(4, 5, 6))
# height <- data.frame(y1 = c(3, 2, 1),
#                      y2 = c(6, 5, 4))
# list_test <- list(days, height)
# names(list_test) <- c("days","height")
#
#
# test_codebook <- codebook(
#   df = study,
#   title = "Test study",
#   description = "Testing! Testing",
#   custom_summary_stats_list = list_test
# )
#
# print(test_codebook, "test.docx")
