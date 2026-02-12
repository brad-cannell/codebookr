# Optionally Add Title and Subtitle to Codebook

This function is not intended to be a stand-alone function. It is
indented to be used by the `codebook` function.

## Usage

``` r
cb_add_title(rdocx, title = NA, subtitle = NA)
```

## Arguments

- rdocx:

  rdocx object created with
  [`officer::read_docx()`](https://davidgohel.github.io/officer/reference/read_docx.html)

- title:

  Optional title

- subtitle:

  Optional subtitle

## Value

rdocx object
