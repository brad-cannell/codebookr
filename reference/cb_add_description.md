# Add Description Text to Codebook

Basically, just checks for the number of paragraphs in the description
and then runs cb_add_text for each one.

## Usage

``` r
cb_add_description(rdocx, description)
```

## Arguments

- rdocx:

  rdocx rdocx object created with
  [`officer::read_docx()`](https://davidgohel.github.io/officer/reference/read_docx.html)

- description:

  Text description of the dataset

## Value

rdocx object
