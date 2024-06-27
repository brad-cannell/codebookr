#' Add Attributes to Columns
#'
#' @description Add arbitrary attributes to columns (e.g., description, source,
#'   column type). These attributes can later be accessed to fill in the column
#'   attributes table.
#'
#' @details Typically, though not necessarily, the first step in creating your
#'   codebook will be to add column attributes to your data. The
#'   `cb_add_col_attributes()` function is a convenience function that allows
#'   you to add arbitrary attributes to the columns of the data frame. These
#'   attributes can later be accessed to fill in the column attributes table of
#'   the codebook document. Column attributes _can_ serve a similar function to
#'   variable labels in SAS or Stata; however, you can assign many different
#'   attributes to a column and they can contain any kind of information you
#'   want.
#'
#'   Although the `cb_add_col_attributes()` function will allow you to add any
#'   attributes you want, there are currently **only five** special attributes
#'   that the `codebook()` function will recognize and add to the column
#'   attributes table of the codebook document. They are:
#'
#'   \describe{
#'     \item{description:}{
#'       Although you may add any text you desire to the
#'       `description` attribute, it is intended to be used describe the
#'       question/process that generated the data contained in the column.
#'       Many statistical software packages refer to this as a variable label.
#'       If the data was imported from SAS, Stata, or SPSS with variable labels
#'       using the `haven` package, `codebook` will automatically recognize
#'       them. There is no need to manually create them. However, you may
#'       overwrite the imported variable label for any column by adding a
#'       `description`attribute.}
#'     \item{source:}{
#'       Although you may add any text you desire to the `source`
#'       attribute, it is intended to be used describe where the data contained
#'       in the column originally came from. For example, if the current data
#'       frame was created by merging multiple data sets together, you may want
#'       to use the source attribute to identify the data set it originates
#'       from. As another example, if the current data frame contains
#'       longitudinal data, you may want to use the source attribute to identify
#'       the wave(s) in which data for this column was collected.}
#'     \item{col_type:}{
#'       The `col_type` attribute is intended to provide additional
#'       information above and beyond the `Data type` (i.e., column class) about
#'       the values in the column. For example, you may have a column of 0's
#'       and 1's, which will have a _numeric_ data type. However, you may want
#'       to inform data users that this is really a dummy variable where the
#'       0's and 1's represent discrete categories (No and Yes). Another way to
#'       think about it is that the `Data type` attribute is how _R_
#'       understands the column and the `Column type` attribute is how _humans_
#'       should understand the column.
#'       Currently accepted values are:
#'       \itemize{
#'         \item{`Numeric`}{}
#'         \item{`Categorical`}{}
#'         \item{`Time`}{}
#'       }
#'       Perhaps even more importantly, setting the `col_type` attribute helps
#'       R determine which descriptive statistics to calculate for the bottom
#'       half of the column attributes table. Inside of the `codebook()`
#'       function, the `cb_add_summary_stats()` function will attempt to figure
#'       out whether the column is:
#'       \itemize{
#'         \item{numeric}{}
#'         \item{categorical - many categories (e.g. participant id)}{}
#'         \item{categorical - few categories (e.g. sex)}{}
#'         \item{time - including dates}{}
#'       }
#'       Again, this matters because the table of summary stats shown in the
#'       codebook document depends on the value `cb_add_summary_stats()`
#'       chooses. However, the user can directly tell `cb_add_summary_stats()`
#'       which summary stats to calculate by providing a `col_type` attribute
#'       to a column with one of the following values: `Numeric`,
#'       `Categorical`, or `Time`.}
#'     \item{value_labels:}{
#'       Although you may pass any named vector you desire to the `value_labels`
#'       attribute, it is intended to inform your data users about how to
#'       correctly interpret numerically coded categorical variables. For
#'       example, you may have a column of 0's and 1's that represent discrete
#'       categories (i.e., "No" and "Yes") instead of numerical quantities. In
#'       many other software packages (e.g., SAS, Stata, and SPSS), you can
#'       layer "No" and "Yes" labels on top of the 0's and 1's to improve the
#'       readability of your analysis output. These are commonly referred to
#'       as _value labels_. The R programming language does not really have
#'       value labels in the same way that other popular statistical software
#'       applications do. R users can (and typically should) coerce numerically
#'       coded categorical variables into factors; however, coercing a numeric
#'       vector to a factor is not the same as adding value labels to a numeric
#'       vector because the underlying numeric values can change in the process
#'       of creating the factor. For this, and other reasons, many R programmers
#'       choose to create a _new_ factor version of a numerically encoded
#'       variable as opposed to overwriting/transforming the numerically encoded
#'       variable. In those cases, you may want to inform your data users about
#'       how to correctly interpret numerically coded categorical variables.
#'       Adding value labels to your codebook is one way of doing so.
#'       \itemize{
#'         \item{
#'           Add value labels to columns as a named vector to the
#'           `value_labels` attribute. For example, `value_labels` =
#'           c("No" = 0, "Yes" = 1).
#'         }{}
#'         \item{
#'           If the data was imported from SAS, Stata, or SPSS with value labels
#'           using the `haven` package, `codebook` will automatically recognize
#'           them. There is no need to manually create them. However, you may
#'           overwrite the imported value labels for any column by adding a
#'           `value_labels` attribute as shown in the example below.
#'         }{}
#'       }}
#'     \item{skip_pattern:}{
#'       Although you may add any text you desire to the `skip_pattern`
#'       attribute, it is intended to be used describe skip patterns in the
#'       data collection tools that impact which study participants were exposed
#'       to each study item. For example, If a question in your data was only
#'       asked of participants who were enrolled in the study for at least
#'       10 days, then you may want to add a note like "Not asked if
#'       days < 10" to the skip pattern section of
#'       the column attributes table.}
#'   }
#'
#' @param df Data frame of interest
#' @param attr_csv_path CSV file containing the column attributes.
#' @examples
#'
#' +--------+--------------+------+-----------+-------------------+------------+
#' |variable|description   |source|col_type   |value_labels       |skip_pattern|
#' +========+==============+======+===========+===================+============+
#' |id      |Study         |study |           |                   |            |
#' |        |identification|      |           |                   |            |
#' |        |variable      |      |           |                   |            |
#' +--------+--------------+------+-----------+-------------------+------------+
#' |likert  |An example    |study |Categorical|c(                 |Not asked if|
#' |        |Likert scale  |      |           |"Very dissatisfied"|days < 10   |
#' |        |item          |      |           |              = 1, |            |
#' |        |              |      |           |"Somewhat          |            |
#' |        |              |      |           |dissatisfied" = 2, |            |
#' |        |              |      |           |"Neither satisfied |            |
#' |        |              |      |           |nor dissatisfied   |            |
#' |        |              |      |           |              = 3, |            |
#' |        |              |      |           |"Somewhat satisfied|            |
#' |        |              |      |           |              = 4, |            |
#' |        |              |      |           |"Very satisfied    |            |
#' |        |              |      |           |              = 5) |            |
#' +--------+--------------+------+-----------+-------------------+------------+
#'
#' @return Returns the same data frame (or tibble) passed to the `df` argument
#'   with column attributes added.
#' @export
#'

cb_add_column_attributes_from_csv_file <- function(df, attr_csv_path){

  # Read csv file, with empty strings and "NA" represented by NA.
  attr_df <- read.csv(attr_csv_path, na.strings=c("","NA"))

  # Initialize empty large list of attributes
  attr_list <- list()

  # Create list of variable names
  attr_vars <- attr_df |> select(variable) |> as.vector() |> unlist()

  # Iteratively add list of attributes from input attributes data frame for each
  # variable to the large nested list
  for (i in attr_vars){
    var_attr <- attr_df |> filter(variable == i) |> select(-c(variable)) |>
      as.list()

    # Remove any elements with missing values
    var_attr <- Filter(Negate(anyNA), var_attr)

    # Add attributes to large list
    attr_list <- append(attr_list, list(var_attr))
  }

  # Name each sublist by variable
  names(attr_list) <- attr_vars

  for (i in attr_vars){
    # Convert input strings of value_labels to named lists
    attr_list[[i]][["value_labels"]] <- eval(
      parse(
        text = attr_list[[i]]["value_labels"]
        )
      )
    # Set df attributes from nested list of attributes
    attributes(df[[i]]) <- attr_list[[i]]
  }
  df
}

# # Test
# # Set column attributes
# test_study <- cb_add_column_attributes_from_csv_file(df = study,
# attr_csv_path = here::here("data", "test_attributes.csv"))
#
# # Generate codebook
# test_codebook <- codebook(
#   df = test_study,
#   title = "Test study",
#   description = "Testing! Testing"
# )
#
# print(test_codebook, "test.docx")
