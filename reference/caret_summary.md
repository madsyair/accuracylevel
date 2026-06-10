# Create Custom caret Metrics

Create a summary function for use with caret's `trainControl`. Returns
L1 accuracy for all four metrics plus traditional metrics.

## Usage

``` r
caret_summary(threshold = NULL)
```

## Arguments

- threshold:

  An optional `al_threshold` object for consistent thresholds across
  folds. If `NULL`, thresholds are calculated per fold.

## Value

A function suitable for `summaryFunction` in
[`caret::trainControl`](https://rdrr.io/pkg/caret/man/trainControl.html).

## Examples

``` r
# \donttest{
if (requireNamespace("caret", quietly = TRUE)) {
  al_summary <- caret_summary()
}
# }
```
