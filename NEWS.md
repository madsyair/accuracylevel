# accuracylevel 0.1.0

Initial release. The package implements the accuracy-level evaluation
metrics of Agustini, Fithriasari, and Prastyo (2026)
<doi:10.1016/j.dajour.2025.100661>.

## Features

* Four accuracy-level metrics on a 0-100% scale: Counted Squared Error
  (`cse()`), Counted Absolute Error (`cae()`), Counted Absolute Percentage
  Error (`cape()`), and Symmetric Counted Absolute Percentage Error
  (`scape()`), plus `accuracy_level()` for all four at once.
* Baseline threshold tools: `calculate_threshold()` and `auto_threshold()`,
  with quartiles computed from the inverse empirical CDF (`type = 1`) to match
  the paper.
* `compare_models()` implements the Figure 3 model-selection rule: Level-1
  accuracy first, ties broken by the level's mean error (lower is better)
  before advancing to the next level. The comparison table reports accuracy
  and mean error per level.
* Conventional and robust benchmarks: `conventional_metrics()` (R-squared,
  RMSE, NRMSE, MAE, MAPE, SMAPE), `robust_metrics()` (MedAE, trimmed MSE,
  Huber loss, quantile loss), and `compare_all_metrics()`.
* Framework integration: `caret_summary()` / `caret_summary_extended()` /
  `caret_single_metric()` for `caret`; `cse_l1()`, `cae_l1()`, `cape_l1()`,
  `scape_l1()`, `accuracy_level_metrics()`, and `al_metric_set()` for
  `tidymodels`/`yardstick`; `al_forecast_accuracy()`, `al_compare_forecasts()`,
  `al_extended_accuracy()`, and `al_tsCV()` for `forecast`.
* `vignette("replication")` reproduces the simple-case (Table 4-6),
  regression-with-outlier, and time-series results, plus the
  caret/tidymodels/forecast integrations. The imputation case study is
  omitted because it relies on confidential firm-level microdata from
  BPS-Statistics Indonesia that cannot be redistributed.

## Data and licensing

The package ships no datasets. The data used in the source article are
referenced by link rather than redistributed: the simple-regression and
candy-production series are public on Kaggle (the candy series originates
from the public-domain FRED series `IPG3113N`), while the firm turnover
microdata are confidential BPS-Statistics Indonesia survey microdata and are
not redistributable. Examples and the vignette use small, reproducible
simulated data generated inline.

## Implementation notes

* Perfect predictions (`actual == predicted`) give a zero baseline threshold;
  a machine-epsilon boundary is used so that exact-zero errors are assigned to
  Level 1.
* Non-finite per-observation errors (for example absolute percentage error
  when an actual value is zero) are assigned to Level 4.
* When a pre-computed threshold object is supplied to `accuracy_level()`, all
  four per-error-type thresholds derive from the stored baseline quartiles, so
  every model is evaluated against the same baseline (Figure 2 of the paper).
