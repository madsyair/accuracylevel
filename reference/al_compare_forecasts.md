# Compare Multiple Forecast Models

Compare Multiple Forecast Models

## Usage

``` r
al_compare_forecasts(
  ...,
  test = NULL,
  metric = c("cae", "cape", "cse", "scape"),
  threshold = NULL
)
```

## Arguments

- ...:

  Named forecast objects or named lists with `forecast` and `test`
  elements.

- test:

  Test data (used when forecast objects are supplied directly).

- metric:

  Metric for determining the optimal model.

- threshold:

  Shared `al_threshold` object or `NULL`.

## Value

A list with `optimal_model`, `comparison` table, and `full_results`.

## Examples

``` r
# \donttest{
actual <- c(10, 20, 30, 40, 50)
res <- al_compare_forecasts(
  A = list(forecast = c(11, 19, 32, 38, 51), test = actual),
  B = list(forecast = c(15, 25, 35, 45, 55), test = actual)
)
res$comparison
#>   Model CSE_L1 CSE_L2 CSE_L3 CSE_L4 CAE_L1 CAE_L2 CAE_L3 CAE_L4 CAPE_L1 CAPE_L2
#> 1     A     60     40      0      0     60     40      0      0      60      40
#> 2     B      0    100      0      0      0    100      0      0      20      40
#>   CAPE_L3 CAPE_L4 SCAPE_L1 SCAPE_L2 SCAPE_L3 SCAPE_L4
#> 1       0       0       60       40        0        0
#> 2      40       0       20       60       20        0
# }
```
