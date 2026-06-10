# Calculate Absolute Error

Compute absolute error between actual and predicted values, as defined
in Equation (2) of Agustini et al. (2026).

## Usage

``` r
absolute_error(actual, predicted, na.rm = FALSE)
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

Numeric vector of absolute errors.

## Examples

``` r
actual <- c(10, 20, 30, 40, 50)
predicted <- c(11, 19, 32, 38, 51)
absolute_error(actual, predicted)
#> [1] 1 1 2 2 1
```
