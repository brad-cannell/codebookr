# Get Column Attributes

Used in codebook() to create the top half of the column attributes
table.

## Usage

``` r
cb_get_col_attributes(df, .x, keep_blank_attributes = keep_blank_attributes)
```

## Arguments

- df:

  Data frame of interest

- .x:

  Column of interest in df

- keep_blank_attributes:

  By default, the column attributes table will omit the Column
  description, Source information, Column type, and value labels rows
  from the column attributes table in the codebook document if those
  attributes haven't been set. In other words, it won't show blank rows
  for those attributes. Passing `TRUE` to the keep_blank_attributes
  argument will cause the opposite to happen. The column attributes
  table will include a Column description, Source information, Column
  type, and value labels row for every column in the data frame - even
  if they don't have a value.

## Value

A tibble of column attributes

## Details

Typically, though not necessarily, the first step in creating your
codebook will be to add column attributes to your data. The
[`cb_add_col_attributes()`](https://brad-cannell.github.io/codebookr/reference/cb_add_col_attributes.md)
function is a convenience function that allows you to add arbitrary
attributes to columns (e.g., description, source, column type). These
attributes can later be accessed to fill in the column attributes table
of the codebook document. Column attributes *can* serve a similar
function to variable labels in SAS or Stata; however, you can assign
many different attributes to a column and they can contain any kind of
information you want.

Although the
[`cb_add_col_attributes()`](https://brad-cannell.github.io/codebookr/reference/cb_add_col_attributes.md)
function will allow you to add any attributes you want, there are
currently **only four** special attributes that the
[`codebook()`](https://brad-cannell.github.io/codebookr/reference/codebook.md)
function (via `cb_get_col_attributes()`) will recognize and add to the
column attributes table of the codebook document. They are:

- **description**: Although you may add any text you desire to the
  `description` attribute, it is intended to be used to describe the
  question/process that generated the data contained in the column. Many
  statistical software packages refer to this as a variable label.

- **source**: Although you may add any text you desire to the `source`
  attribute, it is intended to be used to describe where the data
  contained in the column originally came from. For example, if the
  current data frame was created by merging multiple data sets together,
  you may want to use the source attribute to identify the data set it
  originates from. As another example, if the current data frame
  contains longitudinal data, you may want to use the source attribute
  to identify the wave(s) in which data for this column was collected.

- **col_type**: The `col_type` attribute is intended to provide
  additional information above and beyond the `Data type` (i.e., column
  class) about the values in the column. For example, you may have a
  column of 0's and 1's, which will have a *numeric* data type. However,
  you may want to inform data users that this is really a dummy variable
  where the 0's and 1's represent discrete categories (No and Yes).
  Another way to think about it is that the `Data type` attribute is how
  *R* understands the column and the `Column type` attribute is how
  *humans* should understand the column. Currently accepted values are:
  `Numeric`, `Categorical`, or `Time`.

  - Perhaps even more importantly, setting the `col_type` attribute
    helps R determine which descriptive statistics to calculate for the
    bottom half of the column attributes table. Inside of the
    [`codebook()`](https://brad-cannell.github.io/codebookr/reference/codebook.md)
    function, the
    [`cb_add_summary_stats()`](https://brad-cannell.github.io/codebookr/reference/cb_add_summary_stats.md)
    function will attempt to figure out whether the column is
    **numeric**, **categorical - many categories (e.g. participant
    id)**, **categorical - few categories (e.g. sex)**, or **time -
    including dates**. Again, this matters because the table of summary
    stats shown in the codebook document depends on the value
    [`cb_add_summary_stats()`](https://brad-cannell.github.io/codebookr/reference/cb_add_summary_stats.md)
    chooses. However, the user can directly tell
    [`cb_add_summary_stats()`](https://brad-cannell.github.io/codebookr/reference/cb_add_summary_stats.md)
    which summary stats to calculate by providing by adding a `col_type`
    attribute to a column with one of the following values: `Numeric`,
    `Categorical`, or `Time`.

- **value_labels**: Although you may pass any named vector you desire to
  the `value_labels` attribute, it is intended to inform your data users
  about how to correctly interpret numerically coded categorical
  variables. For example, you may have a column of 0's and 1's that
  represent discrete categories (i.e., "No" and "Yes") instead of
  numerical quantities. In some many other software packages (e.g., SAS,
  Stata, and SPSS), you can layer "No" and "Yes" labels on top of the
  0's and 1's to improve the readability of your analysis output. These
  are commonly referred to as *value labels*. The R programming language
  does not really have value labels in the same way that other popular
  statistical software applications do. R users can (and typically
  should) coerce numerically coded categorical variables into
  [factors](https://www.r4epi.com/numerical-descriptions-of-categorical-variables.html#factor-vectors);
  however, coercing a numeric vector to a factor is not the same as
  adding value labels to a numeric vector because the underlying numeric
  values can change in the process of creating the factor. For this, and
  other reasons, many R programmers choose to create a *new* factor
  version of a numerically encoded variable as opposed to
  overwriting/transforming the numerically encoded variable. In those
  cases, you may want to inform your data users about how to correctly
  interpret numerically coded categorical variables. Adding value labels
  to your codebook is one way of doing so.
