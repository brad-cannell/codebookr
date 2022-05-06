
<!-- README.md is generated from README.Rmd. Please edit that file -->

# codebookr

<!-- badges: start -->
<!-- badges: end -->

The codebook package is intended to make it easy for users to create
codebooks (i.e. data dictionaries) directly from data frame.

## Installation

You can install the development version of codebook like so:

``` r
# install.packages("devtools")
devtools::install_github("brad-cannell/codebook")
```

## Exported functions

-   codebook: The codebook function assists with the creation of a
    codebook for a given data frame.

-   cb_add_col_attributes: Add arbitrary attributes to columns (e.g.,
    description, source, column type). These attributes can later be
    accessed to fill in the column attributes table. Note: Column type
    is the type I say it is: categorical or numeric, Data type is what
    the computer says it is.

## Simple example

This simple example demonstrates how to use the `codebook` package to
make a codebook from a **labeled** data frame.

``` r
library(codebookr)
library(dplyr, warn.conflicts = FALSE)
```

### Load data

By default, `codebookr` assumes that you want to make a codebook about a
dataset file that you have saved somewhere, as opposed to a data frame
you’re working on in an r session, but don’t intend to save. Therefore,
the first thing you will need to do is read the data into the current R
session.

For the purposes of making a self-contained example, the codebook
package comes with a small example data frame that is intended to have
some of the features of real study data. We will use it to demonstrate
how to use `codebook` below.

``` r
# Load example data
data(study)
```

``` r
glimpse(study)
#> Rows: 20
#> Columns: 4
#> $ id     <fct> 1001, 1002, NA, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011,…
#> $ sex    <chr> "Female", "Female", "Female", NA, "Female", "Male", "Male", "Ma…
#> $ date   <date> 2021-10-12, 2021-09-23, 2021-10-13, 2021-10-19, NA, 2021-10-10…
#> $ height <dbl> 63.71109, 64.74961, 54.13307, 79.37787, 72.53373, NA, 83.53815,…
```

### Column types

`codebook` classifies all columns as one of four types and uses these
categories to determine which descriptive statistics are given in the
codebook document:

1.  Categorical with many different categories, for example the `id`
    column of the `study` data frame.  
2.  Categorical with few different categories, for example the `gender`
    column of the `study` data frame.  
3.  Date, for example the `date` column of the `study` data frame.  
4.  Numeric, for example the `height` column of the `study` data frame.

### Add column attributes

``` r
# study <- 
study %>% 
  cb_add_col_attributes(
    id,
    description = "Study identification variable"
  ) %>%

  cb_add_col_attributes(
    sex,
    description = "Biological sex of the participant assigned at birth."
  ) %>%
  
  cb_add_col_attributes(
    date,
    description = "Date of enrollment into study."
  ) %>%
  
  cb_add_col_attributes(
    height,
    description = "Participant's height in inches at date of enrollment."
  ) 
#> The following attribute(s) are being added to a variable in the data frame for the first time: description. Check for typos.
#> # A tibble: 20 × 4
#>    id    sex    date       height
#>    <fct> <chr>  <date>      <dbl>
#>  1 1001  Female 2021-10-12   63.7
#>  2 1002  Female 2021-09-23   64.7
#>  3 <NA>  Female 2021-10-13   54.1
#>  4 1004  <NA>   2021-10-19   79.4
#>  5 1005  Female NA           72.5
#>  6 1006  Male   2021-10-10   NA  
#>  7 1007  Male   2021-09-21   83.5
#>  8 1008  Male   2021-10-26   75.3
#>  9 1009  Female 2021-09-23   68.0
#> 10 1010  Female 2021-10-03   80.0
#> 11 1011  Male   2021-10-20   79.8
#> 12 1012  Male   2021-09-28   79.2
#> 13 1013  Male   2021-10-01   77.9
#> 14 1014  Female 2021-10-23   76.5
#> 15 1015  Male   2021-09-26   70.4
#> 16 1016  Female 2021-09-29   67.9
#> 17 1017  Male   2021-10-16   67.2
#> 18 1018  Female 2021-10-26   64.1
#> 19 1019  Female 2021-09-21   68.9
#> 20 1020  Female 2021-09-23   58.3
```

Get a chunk of code for each column in the data and then copy and paste
below.

``` r
for (i in seq_along(names(study))) {
cat(paste0('
  codebook_add_col_attributes( \n    ',
    names(study)[i], ', \n    ',
    'description = ""
  ) %>%
'))
}
#> 
#>   codebook_add_col_attributes( 
#>     id, 
#>     description = ""
#>   ) %>%
#> 
#>   codebook_add_col_attributes( 
#>     sex, 
#>     description = ""
#>   ) %>%
#> 
#>   codebook_add_col_attributes( 
#>     date, 
#>     description = ""
#>   ) %>%
#> 
#>   codebook_add_col_attributes( 
#>     height, 
#>     description = ""
#>   ) %>%
```
