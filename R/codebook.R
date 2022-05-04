#' Automate creation of a data codebook
#'
#' The codebook function assists with the creation of a codebook for a given
#'  data frame.
#'
#' Codebook expects that `df ` is a data frame that you have read into memory
#' from a saved data file. Please provide the path to the saved data file. This
#' function gets selected attributes about file saved at `path` and stores
#' those attributes in a data frame, which is later turned into a flextable and
#' added to the codebook document.
#'
#' @param df The saved file at `path`, read into memory as a data frame
#' @param path The path to the saved dataset of interest
#' @param title Optional title
#' @param subtitle Optional subtitle
#' @param description Text description of the dataset
#'
#' @return An rdocx object that can be printed to a Word document
#' @importFrom dplyr %>%
#' @export
#'
#' @examples
#' # codebook_detect_5wk <- codebook(
#' #   df = detect_5wk %>% select(1:2),
#' #   path = "../data/detect_5wk.csv",
#' #   title = "Detection of Elder abuse Through Emergency Care Technicians (DETECT)",
#' #   subtitle = "5-Week Pilot Study",
#' #   description = description
#' # ) %>%
#' #   print(target = "example_officer_codebook.docx")
codebook <- function(df, path = NA, title = NA, subtitle = NA, description = NA) {

  # ===========================================================================
  # Variable management
  # ===========================================================================


  # ===========================================================================
  # Checks
  # ===========================================================================
  # Check to make sure df is a data frame
  if ( !("data.frame" %in% class(df)) ) {
    stop("Expecting df to be of class data.frame. Instead it was ", class(df))
  }

  # Check to make sure the user is not piping in the dataset name
  df_name <- deparse(substitute(df))
  if (df_name == ".") {
    message("The function get_df_attributes is seeing '.' as the df name. ",
            "This can be caused by piping df into the get_df_attributes fucntion.")
  }

  # Check for file path
  if (is.na(path)) {
    stop("Codebook expects that df is a data frame that you have read ",
         "into memory from a saved data file. Please provide the path ",
         "to the saved data file.")
  }

  # Check that file path is valid
  if (!file.exists(path)) {
    stop("The argument to 'path' is not a valid file path.")
  }

  # ===========================================================================
  # Create an empty Word rdocx object
  # default template contains only an empty paragraph
  # Using cursor_begin and body_remove, we can delete it
  # ===========================================================================
  rdocx <- officer::read_docx() %>%
    officer::cursor_begin() %>%
    officer::body_remove()

  # ===========================================================================
  # Optionally add title and subtitle to top of codebook
  # ===========================================================================
  cb_shell <- cb_add_title(
    rdocx = rdocx,
    title = title,
    subtitle = subtitle
  )

  # ===========================================================================
  # Copy code from utils:::format.object_size
  # Can't use ::: operator on CRAN
  # ===========================================================================
  format_object_size <- function (x, units = "b", standard = "auto", digits = 1L, ...) {
    known_bases <- c(legacy = 1024, IEC = 1024, SI = 1000)
    known_units <- list(
      SI = c("B", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"),
      IEC = c("B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"),
      legacy = c("b", "Kb", "Mb", "Gb", "Tb", "Pb"),
      LEGACY = c("B", "KB", "MB", "GB", "TB", "PB")
    )
    units <- match.arg(units, c("auto", unique(unlist(known_units), use.names = FALSE)))
    standard <- match.arg(standard, c("auto", names(known_bases)))

    if (standard == "auto") {
      standard <- "legacy"
      if (units != "auto") {
        if (grepl("iB$", units)) {
          standard <- "IEC"
        } else if (grepl("b$", units)) {
          standard <- "legacy"
        } else if (units == "kB") {
          stop("For SI units, specify 'standard = \"SI\"'")
        }
      }
    }

    base <- known_bases[[standard]]
    units_map <- known_units[[standard]]

    if (units == "auto") {
      power <- if (x <= 0) {
        0L
      } else {
        min(as.integer(log(x, base = base)), length(units_map) - 1L)
      }
    } else {
      power <- match(toupper(units), toupper(units_map)) - 1L
      if (is.na(power)) {
        stop(gettextf(
          "Unit \"%s\" is not part of standard \"%s\"",
          sQuote(units), sQuote(standard)), domain = NA
        )
      }
    }

    unit <- units_map[power + 1L]
    if (power == 0 && standard == "legacy") {
      unit <- "bytes"
    }
    paste(round(x/base^power, digits = digits), unit)
  }

  # ===========================================================================
  # Add metadata to codebook shell
  # ===========================================================================
  # Create tibble of metadata
  meta <- tibble::tibble(
    `Dataset name:` = df_name,
    `Dataset size:` = df %>% utils::object.size() %>% format_object_size(units = "auto"),
    `Column count:` = df %>% ncol() %>% format(big.mark = ","),
    `Row count:` = df %>% nrow() %>% format(big.mark = ","),
    `Last modified date:` = file.mtime(path) %>% as.character()
  ) %>%
    tidyr::gather() %>%  # Reorient the data frame vertically
    flextable::regulartable() %>% # Convert to flextable
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
      cb_get_col_attributes(col_nms[[i]]) %>%
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

