# Create Extended caret Summary with All Levels

Create Extended caret Summary with All Levels

## Usage

``` r
caret_summary_extended(threshold = NULL)
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
  al_ext <- caret_summary_extended()
}
# }
```
