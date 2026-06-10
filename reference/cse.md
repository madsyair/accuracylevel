# Counted Squared Error (CSE)

Compute the Counted Squared Error metric at a specified level.

## Usage

``` r
cse(
  actual,
  predicted,
  level = 1,
  threshold = NULL,
  baseline_actual = NULL,
  baseline_predicted = NULL,
  as_decimal = FALSE
)
```

## Arguments

- actual:

  Numeric vector of actual (observed) values.

- predicted:

  Numeric vector of predicted values.

- level:

  Integer (1–4). Level to return. Default is 1.

- threshold:

  An `al_threshold` object or `NULL` for automatic calculation.

- baseline_actual:

  Actual values for baseline model threshold calculation (used only if
  `threshold` is `NULL`).

- baseline_predicted:

  Predicted values for baseline model threshold calculation (used only
  if `threshold` is `NULL`).

- as_decimal:

  Logical. If `TRUE`, return as proportion (0–1); if `FALSE` (default),
  return as percentage (0–100).

## Value

Numeric scalar: the percentage (or proportion) of observations at the
specified accuracy level.

## Examples

``` r
actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
predicted <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)

cse(actual, predicted, level = 1)
#> [1] 40
sapply(1:4, function(l) cse(actual, predicted, level = l))
#> [1] 40 30 30  0
```
