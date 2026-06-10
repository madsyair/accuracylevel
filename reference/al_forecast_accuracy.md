# Accuracy-Level Metrics for Forecast Objects

Calculate accuracy-level metrics for forecast objects from the forecast
package, or for plain numeric predictions.

## Usage

``` r
al_forecast_accuracy(object, test, threshold = NULL)

# Default S3 method
al_forecast_accuracy(object, test, threshold = NULL)

# S3 method for class 'forecast'
al_forecast_accuracy(object, test, threshold = NULL)
```

## Arguments

- object:

  A forecast object or numeric vector of predictions.

- test:

  Numeric vector or time series of test (actual) values.

- threshold:

  An `al_threshold` object or `NULL`.

## Value

An `accuracy_level` object.

## Examples

``` r
# \donttest{
# With plain numeric vectors
pred <- c(11, 19, 32, 38, 51)
actual <- c(10, 20, 30, 40, 50)
al_forecast_accuracy(pred, actual)
#> Accuracy-Level Metrics
#> ======================
#> Observations: 5 
#> Threshold quartile: Q3
#> Multipliers: 2, 5 
#> 
#> Accuracy by Level (%):
#>  Level CSE CAE CAPE SCAPE
#>     L1  60  60   60    60
#>     L2  40  40   40    40
#>     L3   0   0    0     0
#>     L4   0   0    0     0
#> 
#> Interpretation:
#>   L1: Highest accuracy (error < T)
#>   L4: Lowest accuracy  (error >= 5T)
#>   Higher L1 values indicate better model performance.
# }
```
