# Counted Absolute Error (CAE)

Counted Absolute Error (CAE)

## Usage

``` r
cae(
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

Numeric scalar.

## Examples

``` r
actual <- c(10, 20, 30, 40, 50)
predicted <- c(11, 19, 32, 38, 51)
cae(actual, predicted, level = 1)
#> [1] 60
```
