# Create Formatted Flextable From Summary Statistics

Create Formatted Flextable From Summary Statistics

## Usage

``` r
cb_summary_stats_to_ft(df, ...)

# S3 method for class 'summary_numeric'
cb_summary_stats_to_ft(df, col_width = 1.3, ...)

# S3 method for class 'summary_many_cats'
cb_summary_stats_to_ft(df, col_width = 1.62, ...)

# S3 method for class 'summary_few_cats'
cb_summary_stats_to_ft(df, col_width = 1.62, ...)

# S3 method for class 'summary_time'
cb_summary_stats_to_ft(df, col_width = 1.62, ...)
```

## Arguments

- df:

  Data frame of summary statistics

- ...:

  Other stuff

- col_width:

  Set the width of the column that will appear in the Word table

## Value

Flextable object
