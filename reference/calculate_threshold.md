# Calculate Error Thresholds from a Baseline Model

Calculate error threshold levels based on a baseline model's error
distribution. The threshold is determined using quartiles of the
specified error type, following the procedure in Figure 2 of Agustini et
al. (2026).

Quartiles are computed using the inverse empirical CDF (R's `type = 1`),
consistent with the paper.

## Usage

``` r
calculate_threshold(
  actual,
  predicted,
  error_type = c("ape", "sape", "se", "ae"),
  quartile = 2,
  multipliers = c(2, 5)
)
```

## Arguments

- actual:

  Numeric vector of actual (observed) values from the baseline model.

- predicted:

  Numeric vector of predicted values from the baseline model.

- error_type:

  Character string specifying the error type used to select the
  quartile. One of `"ape"` (default, absolute percentage error),
  `"sape"` (symmetric APE), `"se"` (squared error), or `"ae"` (absolute
  error).

- quartile:

  Integer (1, 2, or 3) specifying which quartile to use. Default is 2
  (median). The recommended approach from the paper is to select the
  quartile where the APE value is close to 0.1 (10 percent error).

- multipliers:

  Numeric vector of length 2 specifying the multipliers for level
  boundaries. Default is `c(2, 5)`, creating levels L1: error \< T, L2:
  T \<= error \< 2T, L3: 2T \<= error \< 5T, L4: error \>= 5T.

## Value

A list of class `"al_threshold"` with elements: `threshold` (the base
threshold value T), `levels` (a list with L1–L4 boundary pairs),
`error_type` (the error type used), `quartile` (the quartile used),
`multipliers` (the multiplier values), and `baseline_quartiles` (a named
list with the selected quartile value for every error type: se, ae, ape,
sape – this is the key element that lets
[`accuracy_level`](https://madsyair.github.io/accuracylevel/reference/accuracy_level.md)
derive thresholds for all four metrics from a single baseline model).

## References

Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
method for robust evaluation in predictive analytics. *Decision
Analytics Journal*, 18, 100661.
[doi:10.1016/j.dajour.2025.100661](https://doi.org/10.1016/j.dajour.2025.100661)

## See also

[`accuracy_level`](https://madsyair.github.io/accuracylevel/reference/accuracy_level.md),
[`auto_threshold`](https://madsyair.github.io/accuracylevel/reference/auto_threshold.md)

## Examples

``` r
# --- Paper Table 4: simple case, Model 1 as baseline ---
actual  <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
model1  <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)

# Q2 of APE ~ 0.1111, close to the target 0.10
thresh <- calculate_threshold(actual, model1, quartile = 2)
print(thresh)
#> Accuracy-Level Threshold
#> ========================
#> Error type: ape 
#> Quartile: Q2
#> Base threshold (T): 0.1111 
#> Multipliers: 2, 5 
#> 
#> Level Boundaries (ape):
#>   L1: error < 0.1111 
#>   L2: 0.1111 <= error < 0.2222 
#>   L3: 0.2222 <= error < 0.5556 
#>   L4: error >= 0.5556 
#> 
#> Baseline Q2 for all error types:
#>   SE:   0.49 
#>   AE:   0.7 
#>   APE:  0.1111 
#>   sAPE: 0.1176 

# Stricter thresholds via Q1
thresh_q1 <- calculate_threshold(actual, model1, quartile = 1)
```
