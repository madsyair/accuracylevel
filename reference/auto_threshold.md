# Automatic Threshold Selection

Automatically select the best quartile for threshold calculation based
on the absolute percentage error approaching a target value (default
0.1), following the recommendation in Section 3.4.5 of Agustini et al.
(2026).

## Usage

``` r
auto_threshold(
  actual,
  predicted,
  target_ape = 0.1,
  error_type = "ape",
  multipliers = c(2, 5)
)
```

## Arguments

- actual:

  Numeric vector of actual (observed) values.

- predicted:

  Numeric vector of predicted values.

- target_ape:

  Target APE value for threshold selection. Default is 0.1 (10 percent).

- error_type:

  Error type to calculate threshold for. Default is `"ape"`.

- multipliers:

  Numeric vector of multipliers. Default is `c(2, 5)`.

## Value

An `al_threshold` object with automatically selected quartile.

## Examples

``` r
actual <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
predicted <- c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98)
thresh <- auto_threshold(actual, predicted)
print(thresh)
#> Accuracy-Level Threshold
#> ========================
#> Error type: ape 
#> Quartile: Q3
#> Base threshold (T): 0.05 
#> Multipliers: 2, 5 
#> 
#> Level Boundaries (ape):
#>   L1: error < 0.05 
#>   L2: 0.05 <= error < 0.1 
#>   L3: 0.1 <= error < 0.25 
#>   L4: error >= 0.25 
#> 
#> Baseline Q3 for all error types:
#>   SE:   4 
#>   AE:   2 
#>   APE:  0.05 
#>   sAPE: 0.05128 
```
