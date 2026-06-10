# Compute Accuracy-Level Metrics

Calculate accuracy-level metrics (CSE, CAE, CAPE, SCAPE) for evaluating
prediction model performance. These metrics assess the proportion of
observations falling within predefined error threshold levels, providing
a robust and interpretable evaluation on a 0–100\\ scale.

## Usage

``` r
accuracy_level(
  actual,
  predicted,
  threshold = NULL,
  baseline_actual = NULL,
  baseline_predicted = NULL,
  na.rm = FALSE
)
```

## Arguments

- actual:

  Numeric vector of actual (observed) values.

- predicted:

  Numeric vector of predicted values.

- threshold:

  An `al_threshold` object created by
  [`calculate_threshold`](https://madsyair.github.io/accuracylevel/reference/calculate_threshold.md)
  or
  [`auto_threshold`](https://madsyair.github.io/accuracylevel/reference/auto_threshold.md).
  When supplied, the baseline quartiles stored inside this object are
  used to derive per-error-type thresholds (see Details). If `NULL`
  (default), thresholds are automatically determined via
  [`auto_threshold`](https://madsyair.github.io/accuracylevel/reference/auto_threshold.md).

- baseline_actual:

  Numeric vector of actual values from the baseline model. Used only
  when `threshold` is `NULL`.

- baseline_predicted:

  Numeric vector of predicted values from the baseline model. Used only
  when `threshold` is `NULL`.

- na.rm:

  Logical. If `TRUE`, remove `NA` pairs before computing. Default is
  `FALSE`.

## Value

An object of class `"accuracy_level"` with elements: `metrics` (data
frame with accuracy percentages for each level and metric type),
`mean_errors` (data frame with mean errors per level), `threshold` (the
primary threshold object used), `thresholds_all` (per-error-type
threshold objects), `n_obs` (number of observations), and `counts`
(count of observations at each level).

## Details

The accuracy-level method introduces four metrics:

- CSE (Counted Squared Error):

  Proportion of observations within squared error threshold levels.

- CAE (Counted Absolute Error):

  Proportion of observations within absolute error threshold levels.

- CAPE (Counted Absolute Percentage Error):

  Proportion of observations within absolute percentage error threshold
  levels.

- SCAPE (Symmetric Counted Absolute Percentage Error):

  Proportion of observations within symmetric absolute percentage error
  threshold levels.

For each metric, four accuracy levels are defined:

- Level 1: \\\varepsilon \< T\\ (highest accuracy)

- Level 2: \\T \le \varepsilon \< 2T\\

- Level 3: \\2T \le \varepsilon \< 5T\\

- Level 4: \\\varepsilon \ge 5T\\ (lowest accuracy)

where T is the base threshold determined from the **baseline** model's
error distribution. Crucially, thresholds for CSE, CAE, CAPE, and SCAPE
are each derived from the same quartile of the baseline model's SE, AE,
APE, and sAPE respectively (Figure 2 of the paper).

Edge cases are handled as follows: observations with a non-finite error
(for example APE when `actual` is zero, or sAPE when both `actual` and
`predicted` are zero) are assigned to Level 4. When the baseline
threshold T equals zero (a perfectly fitting baseline), a
machine-epsilon boundary is used so that exact-zero errors fall into
Level 1.

## References

Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
method for robust evaluation in predictive analytics. *Decision
Analytics Journal*, 18, 100661.
[doi:10.1016/j.dajour.2025.100661](https://doi.org/10.1016/j.dajour.2025.100661)

## See also

[`calculate_threshold`](https://madsyair.github.io/accuracylevel/reference/calculate_threshold.md),
[`auto_threshold`](https://madsyair.github.io/accuracylevel/reference/auto_threshold.md),
[`cse`](https://madsyair.github.io/accuracylevel/reference/cse.md),
[`cae`](https://madsyair.github.io/accuracylevel/reference/cae.md),
[`cape`](https://madsyair.github.io/accuracylevel/reference/cape.md),
[`scape`](https://madsyair.github.io/accuracylevel/reference/scape.md)

## Examples

``` r
# ---- Paper Table 4: Simple case ----
actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
m1 <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)
m3 <- c(7.01, 6.04, 2.09, 5.11, 9.01, 5.1, 3.01, 4.39, 1, 8.1)

# Model 1 as baseline, Q2
thresh <- calculate_threshold(actual, m1, quartile = 2)

# Evaluate Model 3 (paper expects 90% at L1)
result <- accuracy_level(actual, m3, threshold = thresh)
print(result)
#> Accuracy-Level Metrics
#> ======================
#> Observations: 10 
#> Threshold quartile: Q2
#> Multipliers: 2, 5 
#> 
#> Accuracy by Level (%):
#>  Level CSE CAE CAPE SCAPE
#>     L1  90  90   90    90
#>     L2   0   0    0     0
#>     L3   0   0    0     0
#>     L4  10  10   10    10
#> 
#> Interpretation:
#>   L1: Highest accuracy (error < T)
#>   L4: Lowest accuracy  (error >= 5T)
#>   Higher L1 values indicate better model performance.
```
