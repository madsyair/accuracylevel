# Time Series Cross-Validation with Accuracy-Level Metrics

Time Series Cross-Validation with Accuracy-Level Metrics

## Usage

``` r
al_tsCV(
  y,
  forecastfunction,
  h = 1,
  initial = 10,
  window = NULL,
  metric = c("cae", "cape", "cse", "scape"),
  ...
)
```

## Arguments

- y:

  Numeric time series data.

- forecastfunction:

  Function that accepts `(x, h, ...)` and returns predictions (either a
  forecast object or numeric vector).

- h:

  Forecast horizon.

- initial:

  Initial training window size.

- window:

  Rolling window size (`NULL` for expanding window).

- metric:

  Metric to report.

- ...:

  Additional arguments passed to `forecastfunction`.

## Value

A data frame of class `"al_tsCV"` with per-fold results.

## Examples

``` r
# \donttest{
ma_fc <- function(x, h) rep(mean(x), h)
y <- sin(seq(0, 4 * pi, length.out = 50)) * 10 + 50
res <- al_tsCV(y, ma_fc, h = 5, initial = 20)
print(res)
#> Time Series Cross-Validation Results
#> =====================================
#> 
#> Number of folds: 26 
#> 
#> Summary Statistics:
#>         Metric    Value
#>    Mean_CSE_L1 33.07692
#>    Mean_CAE_L1 33.07692
#>   Mean_CAPE_L1 33.07692
#>  Mean_SCAPE_L1 33.07692
#>      SD_CSE_L1 16.91608
#>      SD_CAE_L1 16.91608
#>     SD_CAPE_L1 16.91608
#>    SD_SCAPE_L1 16.91608
#> 
#> First few folds:
#>  Fold Training_Size Horizon CSE_L1 CAE_L1 CAPE_L1 SCAPE_L1
#>     1            20       5     20     20      20       20
#>     2            21       5     40     40      40       40
#>     3            22       5     60     60      60       60
#>     4            23       5     60     60      60       60
#>     5            24       5     60     60      60       60
#>     6            25       5     40     40      40       40
# }
```
