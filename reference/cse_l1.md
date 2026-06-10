# CSE Level 1 Metric for yardstick

CSE Level 1 Metric for yardstick

## Usage

``` r
cse_l1(data, truth, estimate, na_rm = TRUE, ...)

# S3 method for class 'data.frame'
cse_l1(data, truth, estimate, na_rm = TRUE, ...)
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

A tibble with `.metric`, `.estimator`, `.estimate`.

## Examples

``` r
# \donttest{
if (requireNamespace("rlang", quietly = TRUE)) {
  df <- data.frame(truth = c(10, 20, 30), estimate = c(11, 19, 28))
  cse_l1(df, truth, estimate)
}
#> # A tibble: 1 × 3
#>   .metric .estimator .estimate
#>   <chr>   <chr>          <dbl>
#> 1 cse_l1  standard        66.7
# }
```
