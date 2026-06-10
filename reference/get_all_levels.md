# Get All Levels for a Metric

Convenience function to obtain all four levels at once.

## Usage

``` r
get_all_levels(
  actual,
  predicted,
  metric = c("cse", "cae", "cape", "scape"),
  threshold = NULL,
  baseline_actual = NULL,
  baseline_predicted = NULL
)
```

## Arguments

- actual:

  Numeric vector of actual values.

- predicted:

  Numeric vector of predicted values.

- metric:

  One of `"cse"`, `"cae"`, `"cape"`, `"scape"`.

- threshold:

  An `al_threshold` object or `NULL`.

- baseline_actual:

  Actual values for baseline model.

- baseline_predicted:

  Predicted values for baseline model.

## Value

Named numeric vector of length 4.

## Examples

``` r
actual <- c(10, 20, 30, 40, 50)
predicted <- c(11, 19, 32, 38, 51)
get_all_levels(actual, predicted, "cae")
#> L1 L2 L3 L4 
#> 60 40  0  0 
```
