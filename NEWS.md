# codebookr 0.1.4

* Add option to prevent summary stats table for selected columns. The `no_summary_stats` argument of the `codebook()` function will prevent the summary statistics from being added to column attributes table for any column passed to this argument.

* Update `cb_summary_stats_time()`. Previously, if the mode value for a date/time column was NA, then the Value in the summary stats table looked blank. Now, the mode of non-missing values is returned instead. Additionally, if all values are `NA`, then the summary stats table says that explicitly. 

# codebookr 0.1.3

* Add column numbers to the column attributes tables. See: https://github.com/brad-cannell/codebookr/issues/10

* Make time (i.e., class = hms) columns display in a human readable format as opposed to the underlying numeric value.

* Add support for a 'pkgdown' site.

# codebookr 0.1.2

* Speed up the `codebook()` function when there are many columns. See: https://github.com/brad-cannell/codebookr/issues/17

# codebookr 0.1.1

* Add haven (>= 2.5.0) to DESCRIPTION Imports. This is to prevent errors related to https://github.com/tidyverse/haven/issues/520

# codebookr 0.1.0

* First CRAN submission
