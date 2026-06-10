# Compare All Metric Types

Comprehensive comparison of conventional, robust, and accuracy-level
metrics.

## Usage

``` r
compare_all_metrics(actual, predicted, threshold = NULL)
```

## Arguments

- actual:

  Numeric vector of actual values.

- predicted:

  Numeric vector of predicted values.

- threshold:

  Threshold object for accuracy-level metrics.

## Value

A list of class `"metrics_comparison"` with `conventional`, `robust`,
`accuracy_level`, and `summary` elements.

## Examples

``` r
actual <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
predicted <- c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98)
result <- compare_all_metrics(actual, predicted)
print(result)
#> Metrics Comparison
#> ==================
#> 
#> Conventional Metrics:
#>     Metric  Value
#>  R_squared 0.9962
#>       RMSE 1.7607
#>      NRMSE 0.0320
#>        MAE 1.7000
#>       MAPE 4.1579
#>      SMAPE 4.1168
#> 
#> Robust Metrics:
#>         Metric Value
#>          MedAE  2.00
#>           TMSE  3.25
#>     Huber_Loss  1.20
#>  Quantile_Loss  0.85
#> 
#> Accuracy-Level Metrics (L1 %):
#>   CSE:   30 
#>   CAE:   30 
#>   CAPE:  60 
#>   SCAPE: 60 
```
