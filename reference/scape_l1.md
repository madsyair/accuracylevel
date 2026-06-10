# SCAPE Level 1 Metric for yardstick

SCAPE Level 1 Metric for yardstick

## Usage

``` r
scape_l1(data, truth, estimate, na_rm = TRUE, ...)

# S3 method for class 'data.frame'
scape_l1(data, truth, estimate, na_rm = TRUE, ...)
```

## Arguments

- data:

  A data frame containing truth and estimate columns.

- truth:

  Column name for actual values (unquoted).

- estimate:

  Column name for predicted values (unquoted).

- na_rm:

  Logical. Remove `NA`s? Default `TRUE`.

- ...:

  Additional arguments (ignored).

## Value

A tibble.
