# Calculate Symmetric Absolute Percentage Error

Compute symmetric absolute percentage error between actual and predicted
values, as defined in Equation (4) of Agustini et al. (2026). Note that
the result is on the proportion scale (not multiplied by 100).

## Usage

``` r
symmetric_absolute_percentage_error(actual, predicted, na.rm = FALSE)
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

Numeric vector of symmetric absolute percentage errors. Returns `NaN`
when both actual and predicted are zero.

## Examples

``` r
actual <- c(10, 20, 30, 40, 50)
predicted <- c(11, 19, 32, 38, 51)
symmetric_absolute_percentage_error(actual, predicted)
#> [1] 0.09523810 0.05128205 0.06451613 0.05128205 0.01980198
```
