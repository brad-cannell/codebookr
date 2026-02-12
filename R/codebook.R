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
#' @param omit_na_columns A character vector of column names. Variables in this
#' vector will have all missing values omitted and 'Missing' will not be
#' included as a category for each of these variables in the resulting codebook
#' file.
#' @param custom_stats_cols A character vector of column names. Instead of the
#' default summary statistics tables, customized tables will be generated
#' instead for these columns.
#' @param categorical A logical value (TRUE or FALSE). This value indicates
#' whether the variable of interest should be treated as categorical or numeric
#' while generating custom summary statistics.
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
##' @param custom_funcs_labels A character vector of labels for the customized
#' summary statistics that will appear as the flextable header labels in the
#' resulting codebook.
#' @param html A logical value (TRUE or FALSE). It determines whether the output
#' of the `codebook function` should be an html temporary file or an rdocx
#' object. The default value is FALSE and it results in the creation of an rdocx
#' object.
#'
#' @return An rdocx object that can be printed to a Word document or an html
#' temporary file which can be relocated to a desired path.
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

# Determine if the output should be html or rdocx object
codebook <- function(..., html = FALSE){

  if(html == FALSE){
    codebook_word(...)
  }

  else if(html == TRUE){
    codebook_html(...)
  }
}

# Create Word version of codebook
codebook_word <- function(
    df, title = NA, subtitle = NA, description = NA,
    keep_blank_attributes = FALSE, no_summary_stats = NULL,
    omit_na_columns = NULL,
    custom_stats_cols = NULL,
    categorical = FALSE,
    custom_funcs = NULL,
    custom_funcs_labels = NULL
) {

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
  rdocx <- officer::read_docx() |>
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
    `Dataset size:` = df |> utils::object.size() |> format(units = "auto"),
    `Column count:` = df |> ncol() |> format(big.mark = ","),
    `Row count:`    = df |> nrow() |> format(big.mark = ","),
    `Updated date:` = Sys.Date()
  )

  # Pivot the metadata to a vertical orientation
  # Must covert all values to character to pivot them into the same column
  meta <- meta |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "key",
      values_to = "value"
    )

  # Convert to flextable
  meta <- meta |>
    flextable::regulartable() |>
    cb_theme_df_attributes() # Format

  # Add metadata to codebook
  rdocx <- rdocx |>
    flextable::body_add_flextable(meta)

  # ===========================================================================
  # Optionally Add dataset description
  # ===========================================================================
  if (!is.na(description)) {
    # Add Description header
    rdocx <- rdocx |>
      cb_add_section_header("Description:")

    # Add dataset description to codebook
    rdocx <- rdocx |>
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
  rdocx <- rdocx |>
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
    table_var_attributes <- df |>
      cb_get_col_attributes(col_nms[[i]], keep_blank_attributes =
                              keep_blank_attributes)
    # Iss 10: Add column number to the column attributes table
    table_var_attributes$Column <- i
    table_var_attributes$Column[-1] <- NA
    table_var_attributes <- table_var_attributes[, c("Column", "Attribute",
                                                     "value")]
    # Make into a flextable and format
    table_var_attributes <- table_var_attributes |>
      flextable::flextable() |>
      cb_theme_col_attr()

    # Add column attributes flextable to the temporary rdocx object
    temp_doc <- temp_doc |>
      flextable::body_add_flextable(table_var_attributes)

    # Get summary statistics
    # Iss 22. Add option to prevent summary stats table for selected columns
    if (!(col_nms[[i]] %in% no_summary_stats) & !(col_nms[[i]] %in%
                                                  custom_stats_cols)) {
      # Add option to remove missing values for each column
      if (!(col_nms[[i]] %in% no_summary_stats) & !(col_nms[[i]] %in%
                                                    custom_stats_cols) &
          col_nms[[i]] %in% omit_na_columns){
        summary_stats <- df |> select(col_nms[[i]]) |> drop_na() |>
          cb_add_summary_stats(col_nms[[i]]) |>
          cb_summary_stats_to_ft()
      }
      else{
        summary_stats <- df |>
          cb_add_summary_stats(col_nms[[i]]) |>
          cb_summary_stats_to_ft()
      }
    }

    # Use summary stats generated by custom functions instead of default summary
    # stats for specified columns
    else if (col_nms[[i]] %in% custom_stats_cols){
      summary_stats <- cb_add_custom_summary_stats(col_nms[[i]], df,
                                                   categorical, custom_funcs) |>
        cb_custom_summary_stats_to_ft(stats_df = _, custom_funcs, custom_funcs_labels)
    }
    # Add summary statistics flextable to the codebook object
    temp_doc <- temp_doc |>
      flextable::body_add_flextable(summary_stats)


    # Create temporary Word document from the temporary rdocx object
    # Put it in one of the temporary files created above the loop.
    print(temp_doc, target = tempfiles[i])
  }

  # tempfiles contains all generated docx paths from the loop. We will
  # iteratively add each of the temporary Word documents to the main
  # rdocx object.
  for (tempfile in tempfiles){
    rdocx <- rdocx |>
      officer::body_add_docx(src = tempfile)
  }

  # ===========================================================================
  # Return rdocx object that can be printed to a Word document
  # ===========================================================================
  rdocx
}

# Create html version of codebook
codebook_html <- function(
    df, title = NA, subtitle = NA, description = NA,
    keep_blank_attributes = FALSE, no_summary_stats = NULL,
    omit_na_columns = NULL,
    custom_stats_cols = NULL,
    categorical = FALSE,
    custom_funcs = NULL,
    custom_funcs_labels = NULL
) {
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

  # Create vector of column names
  col_nms <- names(df)

  # External documents approach to speed up the function
  # Create temporary external files. These will be filled with a single
  # html document for the meta data or attributes or statistics for each column.
  # Then, each temporary html document will be combined with the others
  tmpdir <- tempfile()
  dir.create(tmpdir, showWarnings = FALSE, recursive = TRUE)
  tempfile_meta <-
    file.path(tmpdir, "metadata.rawhtml") # meta data
  tempfiles_attr <-
    file.path(tmpdir, paste0(seq_along(col_nms), "_attr.rawhtml")) # attributes
  tempfiles_stats <-
    file.path(tmpdir, paste0(seq_along(col_nms), "_stats.rawhtml")) # statistics
  tempfiles_comb <-
    file.path(tmpdir, paste0(seq_along(col_nms), "_comb.rawhtml")) # attr+stats
  tempfiles_out <- file.path(tmpdir, "output.rawhtml") # attr + stats + meta

  # ===========================================================================
  # Add metadata to codebook shell
  # ===========================================================================
  # Create tibble of metadata
  meta <- tibble::tibble(
    `Dataset name:` = df_name,
    `Dataset size:` = df |> utils::object.size() |> format(units = "auto"),
    `Column count:` = df |> ncol() |> format(big.mark = ","),
    `Row count:`    = df |> nrow() |> format(big.mark = ","),
    `Updated date:` = Sys.Date()
  )

  # Pivot the metadata to a vertical orientation
  # Must covert all values to character to pivot them into the same column
  meta <- meta |>
    dplyr::mutate(dplyr::across(dplyr::everything(), as.character)) |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      names_to = "key",
      values_to = "value"
    )

  # Convert to flextable
  meta <- meta |>
    flextable::regulartable() |>
    cb_theme_df_attributes() # Format

  # Set font
  font_name <- "Times New Roman"

  # Add column attributes footer
  meta <- meta |>
    # Create and format footer lines
    add_footer_lines("") |>
    add_footer_lines("Column Attributes:") |>
    bold(i = 2, bold = TRUE, part = "footer") |>
    align(align = "left", part = "footer") |>
    fontsize(size = 11, part = "footer")

  # Add optional subtitle
  if (!is.na(subtitle) & is.na(title)){
    meta <- meta |>
      # Create header lines
      add_header_lines(subtitle, top = FALSE) |>
      add_header_lines("", top = FALSE) |> # leave empty line
      # Format header lines
      align(align = "center", part = "header") |>
      fontsize(i = 1, size = 11, part = "header") |>
      font(part = "header", fontname = font_name)
  }

  # Add optional title
  if (!is.na(title) & is.na(subtitle)){
    meta <- meta |>
      # Create header lines
      add_header_lines(title) |>
      add_header_lines("", top = FALSE) |> # leave empty line
      # Format header lines
      align(align = "center", part = "header") |>
      fontsize(i = 1, size = 14, part = "header") |>
      font(part = "header", fontname = font_name)
    # Save as rawhtml file
    flextable::save_as_html(meta, path = tempfile_meta)
  }

  # Add both optional title and subtitle
  if (!is.na(title) & !is.na(subtitle)){
    meta <- meta |>
      # Create header lines
      add_header_lines(title) |>
      add_header_lines(subtitle, top = FALSE) |>
      add_header_lines("", top = FALSE) |> # leave empty line
      # Format header lines
      align(align = "center", part = "header") |>
      fontsize(i = 1, size = 12, part = "header")|>
      fontsize(i = 2, size = 11, part = "header") |>
      font(part = "header", fontname = font_name)
  }

  # Add Codebook title
  meta <- meta |>
    # Create header lines
    add_header_lines("Codebook", top = TRUE) |>
    # Format header lines
    bold(i = c(1), bold = TRUE, part = "header") |>
    fontsize(i = 1, size = 14, part = "header") |>
    font(part = "header", fontname = font_name)

  # Add space between Codebook title and meta data table depending on if title
  # or subtitle are NA
  if (is.na(title) & is.na(subtitle)){
    meta <- meta |>
      # Create header lines
      add_header_lines("", top = FALSE)
  }

  # Add optional description
  if (!is.na(description)){
    meta <- meta |>
      # Create and format footer lines
      add_footer_lines("", top = TRUE) |>
      add_footer_lines(description, top = TRUE) |>
      add_footer_lines("", top = TRUE) |>
      add_footer_lines("Description:", top = TRUE) |>
      add_footer_lines("", top = TRUE) |>
      bold(i = c(2,6), bold = TRUE, part = "footer") |>
      align(align = "left", part = "footer") |>
      fontsize(size = 11, part = "footer") |>
      font(part = "footer", fontname = font_name)
  }

  flextable::save_as_html(meta, path = tempfile_meta)

  # Create vector of column names
  col_nms <- names(df)

  # Iterate over all columns
  # ------------------------
  for (i in seq_along(col_nms)) {

    # Create a temporary rdocx object just for the current column
    # Get column attributes
    table_var_attributes <- df |>
      cb_get_col_attributes(col_nms[[i]], keep_blank_attributes =
                              keep_blank_attributes)
    # Iss 10: Add column number to the column attributes table
    table_var_attributes$Column <- i
    table_var_attributes$Column[-1] <- NA
    table_var_attributes <- table_var_attributes[, c("Column", "Attribute",
                                                     "value")]
    # Make into a flextable and format
    table_var_attributes <- table_var_attributes |>
      flextable::flextable() |>
      cb_theme_col_attr()

    # Add column attributes flextable to the temporary html file
    flextable::save_as_html(table_var_attributes, path = tempfiles_attr[i])

    # Get summary statistics
    # Iss 22. Add option to prevent summary stats table for selected columns
    if (!(col_nms[[i]] %in% no_summary_stats) & !(col_nms[[i]] %in%
                                                  custom_stats_cols)) {
      # Add option to remove missing values for each column
      if (!(col_nms[[i]] %in% no_summary_stats) & !(col_nms[[i]] %in%
                                                    custom_stats_cols) &
          col_nms[[i]] %in% omit_na_columns){
        summary_stats <- df |> select(col_nms[[i]]) |> drop_na() |>
          cb_add_summary_stats(col_nms[[i]]) |>
          cb_summary_stats_to_ft()
      }
      else{
        summary_stats <- df |>
          cb_add_summary_stats(col_nms[[i]]) |>
          cb_summary_stats_to_ft()
      }
    }

    # Use summary stats generated by custom functions instead of default summary
    # stats for specified columns
    else if (col_nms[[i]] %in% custom_stats_cols){
      summary_stats <- cb_add_custom_summary_stats(col_nms[[i]], df,
                                                   categorical, custom_funcs) |>
        cb_custom_summary_stats_to_ft(stats_df = _, custom_funcs, custom_funcs_labels)
    }
    # Add summary statistics flextable to temporary html file
    flextable::save_as_html(summary_stats, path = tempfiles_stats[i])


    # Combine attributes and summary statistics into single html file
    R3port::html_combine(
      combine = list(tempfiles_attr[i], tempfiles_stats[i]),
      out = tempfiles_comb[i],
      toctheme = TRUE,
      css = paste0(system.file(package = "R3port"), "/style.css"),
      clean = 0,
      show = FALSE
    )
  }

  # Combine all the temporary raw html files into a single html file
  R3port::html_combine(
    combine = list(tempfile_meta, as.list(tempfiles_comb)),
    out = tempfiles_out,
    toctheme = TRUE,
    css = paste0(system.file(package = "R3port"), "/style.css"),
    clean = 0,
    show = FALSE
  )

  # ===========================================================================
  # Return path of output html temp file
  # ===========================================================================
  tempfiles_out
}

# # Test
# # data(study)
# # devtools::load_all()
# #
# # Generate Word codebook
# test_codebook <- codebook(
#   df = study,
#   title = "Test study",
#   subtitle = "Subtitle",
#   description = "Here's a description of the test data frame.",
#   custom_stats_cols = c("likert", "sex"),
#   categorical = TRUE,
#   custom_funcs = c("n", "cum_freq", "percent"),
#   custom_funcs_labels = c("Frequency", "Cumulative Frequency", "Percentage")
# )
# #
# # Print codebook as Word file
# file.rename(test_codebook, "desired_path.docx")
#
# Generate html codebook
#
# test_codebook <- codebook(
#   df = study,
#   title = "Test study",
#   subtitle = "Subtitle",
#   description = "Here's a description of the test data frame."
#   custom_stats_cols = c("likert", "sex"),
#   categorical = TRUE,
#   custom_funcs = c("n", "cum_freq", "percent"),
#   custom_funcs_labels = c("Frequency", "Cumulative Frequency", "Percentage"),
#   html = TRUE
# )
# # Move output html to desired location
# file.rename(test_codebook, "test_custom_funcs1.html")
