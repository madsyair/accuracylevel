# Create Single Metric caret Summary

Create Single Metric caret Summary

## Usage

``` r
caret_single_metric(
  metric_type = c("cse", "cae", "cape", "scape"),
  level = 1,
  threshold = NULL
)
```

## Arguments

- metric_type:

  One of `"cse"`, `"cae"`, `"cape"`, `"scape"`.

- level:

  Level to optimise (1–4). Default is 1.

- threshold:

  An `al_threshold` object or `NULL`.

## Value

A function suitable for `summaryFunction` in
[`caret::trainControl`](https://rdrr.io/pkg/caret/man/trainControl.html).

## Examples

``` r
# \donttest{
if (requireNamespace("caret", quietly = TRUE)) {
  fn <- caret_single_metric("cae", level = 1)
}
# }
```
