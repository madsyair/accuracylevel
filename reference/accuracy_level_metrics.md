# Full Accuracy-Level Metrics for yardstick

Full Accuracy-Level Metrics for yardstick

## Usage

``` r
accuracy_level_metrics(data, truth, estimate, na_rm = TRUE, ...)

# S3 method for class 'data.frame'
accuracy_level_metrics(data, truth, estimate, na_rm = TRUE, ...)
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

A tibble with 16 rows (4 metrics x 4 levels).

## Examples

``` r
# \donttest{
if (requireNamespace("rlang", quietly = TRUE)) {
  df <- data.frame(truth = c(10, 20, 30, 40, 50),
                   estimate = c(11, 19, 32, 38, 51))
  accuracy_level_metrics(df, truth, estimate)
}
#> # A tibble: 16 × 3
#>    .metric  .estimator .estimate
#>    <chr>    <chr>          <dbl>
#>  1 cse_l1   standard          60
#>  2 cse_l2   standard          40
#>  3 cse_l3   standard           0
#>  4 cse_l4   standard           0
#>  5 cae_l1   standard          60
#>  6 cae_l2   standard          40
#>  7 cae_l3   standard           0
#>  8 cae_l4   standard           0
#>  9 cape_l1  standard          60
#> 10 cape_l2  standard          40
#> 11 cape_l3  standard           0
#> 12 cape_l4  standard           0
#> 13 scape_l1 standard          60
#> 14 scape_l2 standard          40
#> 15 scape_l3 standard           0
#> 16 scape_l4 standard           0
# }
```
