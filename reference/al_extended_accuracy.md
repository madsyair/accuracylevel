# Extended Forecast Accuracy Summary

Extended Forecast Accuracy Summary

## Usage

``` r
al_extended_accuracy(forecast_obj, test, threshold = NULL)
```

## Arguments

- forecast_obj:

  A forecast object or numeric predictions.

- test:

  Actual test values.

- threshold:

  Optional threshold object.

## Value

A data frame combining traditional and accuracy-level metrics.

## Examples

``` r
# \donttest{
pred <- c(11, 19, 32, 38, 51)
actual <- c(10, 20, 30, 40, 50)
al_extended_accuracy(pred, actual)
#>      Metric     Value           Type
#> 1       MAE  1.400000    Traditional
#> 2      RMSE  1.483240    Traditional
#> 3      MAPE  5.733333    Traditional
#> 4     SMAPE  5.642406    Traditional
#> 5    CSE_L1 60.000000 Accuracy-Level
#> 6    CSE_L2 40.000000 Accuracy-Level
#> 7    CSE_L3  0.000000 Accuracy-Level
#> 8    CSE_L4  0.000000 Accuracy-Level
#> 9    CAE_L1 60.000000 Accuracy-Level
#> 10   CAE_L2 40.000000 Accuracy-Level
#> 11   CAE_L3  0.000000 Accuracy-Level
#> 12   CAE_L4  0.000000 Accuracy-Level
#> 13  CAPE_L1 60.000000 Accuracy-Level
#> 14  CAPE_L2 40.000000 Accuracy-Level
#> 15  CAPE_L3  0.000000 Accuracy-Level
#> 16  CAPE_L4  0.000000 Accuracy-Level
#> 17 SCAPE_L1 60.000000 Accuracy-Level
#> 18 SCAPE_L2 40.000000 Accuracy-Level
#> 19 SCAPE_L3  0.000000 Accuracy-Level
#> 20 SCAPE_L4  0.000000 Accuracy-Level
# }
```
