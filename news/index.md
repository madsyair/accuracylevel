# Changelog

## accuracylevel 0.1.0

Initial release. The package implements the accuracy-level evaluation
metrics of Agustini, Fithriasari, and Prastyo (2026)
<doi:10.1016/j.dajour.2025.100661>.

### Features

- Four accuracy-level metrics on a 0-100% scale: Counted Squared Error
  ([`cse()`](https://madsyair.github.io/accuracylevel/reference/cse.md)),
  Counted Absolute Error
  ([`cae()`](https://madsyair.github.io/accuracylevel/reference/cae.md)),
  Counted Absolute Percentage Error
  ([`cape()`](https://madsyair.github.io/accuracylevel/reference/cape.md)),
  and Symmetric Counted Absolute Percentage Error
  ([`scape()`](https://madsyair.github.io/accuracylevel/reference/scape.md)),
  plus
  [`accuracy_level()`](https://madsyair.github.io/accuracylevel/reference/accuracy_level.md)
  for all four at once.
- Baseline threshold tools:
  [`calculate_threshold()`](https://madsyair.github.io/accuracylevel/reference/calculate_threshold.md)
  and
  [`auto_threshold()`](https://madsyair.github.io/accuracylevel/reference/auto_threshold.md),
  with quartiles computed from the inverse empirical CDF (`type = 1`) to
  match the paper.
- [`compare_models()`](https://madsyair.github.io/accuracylevel/reference/compare_models.md)
  implements the Figure 3 model-selection rule: Level-1 accuracy first,
  ties broken by the level’s mean error (lower is better) before
  advancing to the next level. The comparison table reports accuracy and
  mean error per level.
- Conventional and robust benchmarks:
  [`conventional_metrics()`](https://madsyair.github.io/accuracylevel/reference/conventional_metrics.md)
  (R-squared, RMSE, NRMSE, MAE, MAPE, SMAPE),
  [`robust_metrics()`](https://madsyair.github.io/accuracylevel/reference/robust_metrics.md)
  (MedAE, trimmed MSE, Huber loss, quantile loss), and
  [`compare_all_metrics()`](https://madsyair.github.io/accuracylevel/reference/compare_all_metrics.md).
- Framework integration:
  [`caret_summary()`](https://madsyair.github.io/accuracylevel/reference/caret_summary.md)
  /
  [`caret_summary_extended()`](https://madsyair.github.io/accuracylevel/reference/caret_summary_extended.md)
  /
  [`caret_single_metric()`](https://madsyair.github.io/accuracylevel/reference/caret_single_metric.md)
  for `caret`;
  [`cse_l1()`](https://madsyair.github.io/accuracylevel/reference/cse_l1.md),
  [`cae_l1()`](https://madsyair.github.io/accuracylevel/reference/cae_l1.md),
  [`cape_l1()`](https://madsyair.github.io/accuracylevel/reference/cape_l1.md),
  [`scape_l1()`](https://madsyair.github.io/accuracylevel/reference/scape_l1.md),
  [`accuracy_level_metrics()`](https://madsyair.github.io/accuracylevel/reference/accuracy_level_metrics.md),
  and
  [`al_metric_set()`](https://madsyair.github.io/accuracylevel/reference/al_metric_set.md)
  for `tidymodels`/`yardstick`;
  [`al_forecast_accuracy()`](https://madsyair.github.io/accuracylevel/reference/al_forecast_accuracy.md),
  [`al_compare_forecasts()`](https://madsyair.github.io/accuracylevel/reference/al_compare_forecasts.md),
  [`al_extended_accuracy()`](https://madsyair.github.io/accuracylevel/reference/al_extended_accuracy.md),
  and
  [`al_tsCV()`](https://madsyair.github.io/accuracylevel/reference/al_tsCV.md)
  for `forecast`.
- [`vignette("replication")`](https://madsyair.github.io/accuracylevel/articles/replication.md)
  reproduces the simple-case (Table 4-6), regression-with-outlier, and
  time-series results, plus the caret/tidymodels/forecast integrations.
  The imputation case study is omitted because it relies on confidential
  firm-level microdata from BPS-Statistics Indonesia that cannot be
  redistributed.

### Data and licensing

The package ships no datasets. The data used in the source article are
referenced by link rather than redistributed: the simple-regression and
candy-production series are public on Kaggle (the candy series
originates from the public-domain FRED series `IPG3113N`), while the
firm turnover microdata are confidential BPS-Statistics Indonesia survey
microdata and are not redistributable. Examples and the vignette use
small, reproducible simulated data generated inline.

### Implementation notes

- Perfect predictions (`actual == predicted`) give a zero baseline
  threshold; a machine-epsilon boundary is used so that exact-zero
  errors are assigned to Level 1.
- Non-finite per-observation errors (for example absolute percentage
  error when an actual value is zero) are assigned to Level 4.
- When a pre-computed threshold object is supplied to
  [`accuracy_level()`](https://madsyair.github.io/accuracylevel/reference/accuracy_level.md),
  all four per-error-type thresholds derive from the stored baseline
  quartiles, so every model is evaluated against the same baseline
  (Figure 2 of the paper).
