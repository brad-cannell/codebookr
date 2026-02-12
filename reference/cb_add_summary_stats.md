# Calculate Appropriate Statistics for Variable Type

The input to cb_add_summary_stats is a data frame and a column from that
data frame in the format cb_add_summary_stats(study, "id"). The column
name is a character string because it is passed from a for loop in the
`codebook` function. The purpose of cb_add_summary_stats is to attempt
to figure out whether the column is:

1.  Numeric (e.g., height)

2.  Categorical - many categories (e.g. participant id)

3.  Categorical - few categories (e.g. gender)

4.  Time - including dates

This matters because the table of summary stats shown in the codebook
document depends on the value cb_add_summary_stats chooses.

## Usage

``` r
cb_add_summary_stats(
  df,
  .x,
  many_cats = 10,
  num_to_cat = 4,
  digits = 2,
  n_extreme_cats = 5
)
```

## Arguments

- df:

  Data frame of interest

- .x:

  Column of interest

- many_cats:

  The many_cats argument sets the cutoff value that partially (i.e.,
  along with the col_type attribute) determines whether
  cb_add_summary_stats will categorize the variable as categorical with
  few categories or categorical with many categories. The number of
  categories that constitutes "many" is defined by the value passed to
  the many_cats argument. The default is 10.

- num_to_cat:

  The num_to_cat argument sets the cutoff value that partially (i.e.,
  along with the col_type attribute) determines whether
  cb_add_summary_stats will categorize a numeric as categorical. If the
  col_type attribute is not set for a column AND the number of unique
  non-missing values is \<= num_to_cat, then cb_add_summary_stats will
  guess that the variable is categorical. The default value for
  num_to_cat is 4.

- digits:

  Number of digits after the decimal to display

- n_extreme_cats:

  Number of extreme values to display when the column is classified as
  `many_cats`. By default, the 5 least frequently occurring values and
  the 5 most frequently occurring values are displayed.

## Value

A tibble of results

## Details

The user can tell the cb_add_summary_stats function what to choose
explicitly by giving the column a col_type attribute set to one of the
following values:

1.  Numeric. For example, height and/or weight.

    - `study <- cb_add_col_attributes(study, height, col_type = "numeric")`

2.  Categorical. We describe how many categories vs few categories is
    determined below.

    - `study <- cb_add_col_attributes(study, id, col_type = "categorical")`

3.  Time. Dates, times, and datetimes.

    - `cb_add_col_attributes(study, date, col_type = "time")`

If the user does not explicitly set the col_type attribute to one of
these values, then cb_add_summary_stats will guess which col_type
attribute to assign to each column based on the column's class and the
number of unique non-missing values the it has.

However, the number of unique non-missing values isn't used in an
absolute way (e.g., 10 or more unique values is ALWAYS many_cats).
Instead, the number of unique non-missing values used relative to the
values passed to the many_cats parameter and/or the num_to_cat parameter
– depending on the class of the column.

## See also

Other add_summary_stats:
[`cb_summary_stats_few_cats()`](https://brad-cannell.github.io/codebookr/reference/cb_summary_stats_few_cats.md),
[`cb_summary_stats_many_cats()`](https://brad-cannell.github.io/codebookr/reference/cb_summary_stats_many_cats.md),
[`cb_summary_stats_numeric()`](https://brad-cannell.github.io/codebookr/reference/cb_summary_stats_numeric.md),
[`cb_summary_stats_time()`](https://brad-cannell.github.io/codebookr/reference/cb_summary_stats_time.md)
