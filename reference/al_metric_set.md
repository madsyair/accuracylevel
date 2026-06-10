# Create Metric Set for tidymodels

Create Metric Set for tidymodels

## Usage

``` r
al_metric_set(include_traditional = TRUE)
```

## Arguments

- include_traditional:

  Logical. If `TRUE` (default), also include rmse, mae, and rsq from
  yardstick.

## Value

A metric set function.

## Note

The level-1 metrics in the set derive their error thresholds from the
data being evaluated (a self-referential baseline). In resampling or
cross-validation, each fold therefore uses its own threshold, which
limits strict cross-fold comparability. For a fixed baseline across
folds, evaluate with
[`accuracy_level`](https://madsyair.github.io/accuracylevel/reference/accuracy_level.md)
using a pre-computed `al_threshold` object (see
[`calculate_threshold`](https://madsyair.github.io/accuracylevel/reference/calculate_threshold.md)).
Case weights are not supported; any `case_weights` passed by tune are
ignored.

## Examples

``` r
# \donttest{
if (requireNamespace("yardstick", quietly = TRUE)) {
  al_metrics <- al_metric_set()
}
# }
```
