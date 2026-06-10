# Calculate Conventional Metrics

Compute commonly used evaluation metrics including R-squared, RMSE,
NRMSE, MAE, MAPE, and SMAPE.

## Usage

``` r
conventional_metrics(actual, predicted, na.rm = FALSE)
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

A named numeric vector with six elements.

## Details

`NRMSE` is normalised by the mean of `actual` (returned as `NA` when
that mean is zero). `R_squared` is the usual \\1 - SS\_{res}/SS\_{tot}\\
and may be negative for models worse than the mean (unlike the 0–1 range
quoted in Table 1 of the paper). `MAPE` and `SMAPE` are returned on the
percentage scale and ignore non-finite per-observation terms (e.g.
division by a zero actual value).

## Examples

``` r
actual <- c(10, 20, 30, 40, 50)
predicted <- c(11, 19, 32, 38, 51)
conventional_metrics(actual, predicted)
#>  R_squared       RMSE      NRMSE        MAE       MAPE      SMAPE 
#> 0.98900000 1.48323970 0.04944132 1.40000000 5.73333333 5.64240614 
```
