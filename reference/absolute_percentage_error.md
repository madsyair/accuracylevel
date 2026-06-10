# Calculate Absolute Percentage Error

Compute absolute percentage error between actual and predicted values,
as defined in Equation (3) of Agustini et al. (2026). Note that the
result is on the proportion scale (not multiplied by 100).

## Usage

``` r
absolute_percentage_error(actual, predicted, na.rm = FALSE)
```

## Arguments

- actual:

  Numeric vector of actual (observed) values.

- predicted:

  Numeric vector of predicted values.

- na.rm:

  Logical. If `TRUE`, remove `NA` pairs before computing. Default is
  `FALSE`.

## Value

Numeric vector of absolute percentage errors. Returns `Inf` for
observations where `actual` is zero.

## Examples

``` r
actual <- c(10, 20, 30, 40, 50)
predicted <- c(11, 19, 32, 38, 51)
absolute_percentage_error(actual, predicted)
#> [1] 0.10000000 0.05000000 0.06666667 0.05000000 0.02000000
```
