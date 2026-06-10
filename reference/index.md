# Package index

## Core accuracy-level metrics

Compute the four accuracy-level metrics and inspect the result.

- [`accuracy_level()`](https://madsyair.github.io/accuracylevel/reference/accuracy_level.md)
  : Compute Accuracy-Level Metrics
- [`cse()`](https://madsyair.github.io/accuracylevel/reference/cse.md) :
  Counted Squared Error (CSE)
- [`cae()`](https://madsyair.github.io/accuracylevel/reference/cae.md) :
  Counted Absolute Error (CAE)
- [`cape()`](https://madsyair.github.io/accuracylevel/reference/cape.md)
  : Counted Absolute Percentage Error (CAPE)
- [`scape()`](https://madsyair.github.io/accuracylevel/reference/scape.md)
  : Symmetric Counted Absolute Percentage Error (SCAPE)
- [`get_all_levels()`](https://madsyair.github.io/accuracylevel/reference/get_all_levels.md)
  : Get All Levels for a Metric

## Error thresholds

Build and inspect the baseline error thresholds.

- [`calculate_threshold()`](https://madsyair.github.io/accuracylevel/reference/calculate_threshold.md)
  : Calculate Error Thresholds from a Baseline Model
- [`auto_threshold()`](https://madsyair.github.io/accuracylevel/reference/auto_threshold.md)
  : Automatic Threshold Selection
- [`print(`*`<al_threshold>`*`)`](https://madsyair.github.io/accuracylevel/reference/print.al_threshold.md)
  : Print Method for al_threshold Objects

## Error types

Per-observation error functions used by the metrics.

- [`squared_error()`](https://madsyair.github.io/accuracylevel/reference/squared_error.md)
  : Calculate Squared Error
- [`absolute_error()`](https://madsyair.github.io/accuracylevel/reference/absolute_error.md)
  : Calculate Absolute Error
- [`absolute_percentage_error()`](https://madsyair.github.io/accuracylevel/reference/absolute_percentage_error.md)
  : Calculate Absolute Percentage Error
- [`symmetric_absolute_percentage_error()`](https://madsyair.github.io/accuracylevel/reference/symmetric_absolute_percentage_error.md)
  : Calculate Symmetric Absolute Percentage Error

## Model comparison and benchmarks

Compare models and contrast with conventional and robust metrics.

- [`compare_models()`](https://madsyair.github.io/accuracylevel/reference/compare_models.md)
  : Compare Multiple Models
- [`compare_all_metrics()`](https://madsyair.github.io/accuracylevel/reference/compare_all_metrics.md)
  : Compare All Metric Types
- [`conventional_metrics()`](https://madsyair.github.io/accuracylevel/reference/conventional_metrics.md)
  : Calculate Conventional Metrics
- [`robust_metrics()`](https://madsyair.github.io/accuracylevel/reference/robust_metrics.md)
  : Calculate Robust Metrics

## caret integration

- [`caret_summary()`](https://madsyair.github.io/accuracylevel/reference/caret_summary.md)
  : Create Custom caret Metrics
- [`caret_summary_extended()`](https://madsyair.github.io/accuracylevel/reference/caret_summary_extended.md)
  : Create Extended caret Summary with All Levels
- [`caret_single_metric()`](https://madsyair.github.io/accuracylevel/reference/caret_single_metric.md)
  : Create Single Metric caret Summary

## tidymodels / yardstick integration

- [`accuracy_level_metrics()`](https://madsyair.github.io/accuracylevel/reference/accuracy_level_metrics.md)
  : Full Accuracy-Level Metrics for yardstick
- [`al_metric_set()`](https://madsyair.github.io/accuracylevel/reference/al_metric_set.md)
  : Create Metric Set for tidymodels
- [`cse_l1()`](https://madsyair.github.io/accuracylevel/reference/cse_l1.md)
  : CSE Level 1 Metric for yardstick
- [`cae_l1()`](https://madsyair.github.io/accuracylevel/reference/cae_l1.md)
  : CAE Level 1 Metric for yardstick
- [`cape_l1()`](https://madsyair.github.io/accuracylevel/reference/cape_l1.md)
  : CAPE Level 1 Metric for yardstick
- [`scape_l1()`](https://madsyair.github.io/accuracylevel/reference/scape_l1.md)
  : SCAPE Level 1 Metric for yardstick

## forecast integration

- [`al_forecast_accuracy()`](https://madsyair.github.io/accuracylevel/reference/al_forecast_accuracy.md)
  : Accuracy-Level Metrics for Forecast Objects
- [`al_compare_forecasts()`](https://madsyair.github.io/accuracylevel/reference/al_compare_forecasts.md)
  : Compare Multiple Forecast Models
- [`al_extended_accuracy()`](https://madsyair.github.io/accuracylevel/reference/al_extended_accuracy.md)
  : Extended Forecast Accuracy Summary
- [`al_tsCV()`](https://madsyair.github.io/accuracylevel/reference/al_tsCV.md)
  : Time Series Cross-Validation with Accuracy-Level Metrics

## Package

- [`accuracylevel-package`](https://madsyair.github.io/accuracylevel/reference/accuracylevel-package.md)
  [`accuracylevel`](https://madsyair.github.io/accuracylevel/reference/accuracylevel-package.md)
  : accuracylevel: Robust Accuracy-Level Metrics for Predictive Model
  Evaluation
