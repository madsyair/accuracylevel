# Calculate Robust Metrics

Compute robust evaluation metrics including Median Absolute Error,
Trimmed Mean Squared Error, Huber Loss, and Quantile Loss.

## Usage

``` r
robust_metrics(
  actual,
  predicted,
  trim_percent = 0.1,
  huber_delta = 1,
  tau = 0.5,
  na.rm = FALSE
)
```

## Arguments

- actual:

  Numeric vector of actual (observed) values.

- predicted:

  Numeric vector of predicted values.

- trim_percent:

  Proportion to trim for TMSE (default 0.1).

- huber_delta:

  Delta parameter for Huber loss (default 1).

- tau:

  Quantile for quantile loss (default 0.5 for median).

- na.rm:

  Logical. Default is `FALSE`.

## Value

A named numeric vector with four elements.

## Examples

``` r
actual <- c(10, 20, 30, 40, 50, 1000)
predicted <- c(11, 19, 32, 38, 51, 60)
robust_metrics(actual, predicted)
#>         MedAE          TMSE    Huber_Loss Quantile_Loss 
#>       1.50000  147268.50000     157.33333      78.91667 
```
