# accuracylevel: Robust Accuracy-Level Metrics for Predictive Model Evaluation

The accuracylevel package implements novel accuracy-level metrics for
evaluating continuous data prediction models. These metrics offer
robust, consistent, and interpretable evaluation on a 0–100\\
limitations of conventional metrics like RMSE, MAE, and MAPE.

## Main Functions

- [`accuracy_level`](https://madsyair.github.io/accuracylevel/reference/accuracy_level.md):

  Compute all accuracy-level metrics (CSE, CAE, CAPE, SCAPE).

- [`cse`](https://madsyair.github.io/accuracylevel/reference/cse.md),
  [`cae`](https://madsyair.github.io/accuracylevel/reference/cae.md),
  [`cape`](https://madsyair.github.io/accuracylevel/reference/cape.md),
  [`scape`](https://madsyair.github.io/accuracylevel/reference/scape.md):

  Individual metric convenience functions.

## Threshold Functions

- [`calculate_threshold`](https://madsyair.github.io/accuracylevel/reference/calculate_threshold.md):

  Calculate error thresholds from a baseline model.

- [`auto_threshold`](https://madsyair.github.io/accuracylevel/reference/auto_threshold.md):

  Automatic quartile selection based on a target APE.

## Integration

- [`caret_summary`](https://madsyair.github.io/accuracylevel/reference/caret_summary.md):

  caret package integration.

- [`cse_l1`](https://madsyair.github.io/accuracylevel/reference/cse_l1.md),
  [`cae_l1`](https://madsyair.github.io/accuracylevel/reference/cae_l1.md),
  etc.:

  tidymodels / yardstick integration.

- [`al_forecast_accuracy`](https://madsyair.github.io/accuracylevel/reference/al_forecast_accuracy.md):

  forecast package integration.

## Comparison

- [`conventional_metrics`](https://madsyair.github.io/accuracylevel/reference/conventional_metrics.md):

  RMSE, MAE, MAPE, etc.

- [`robust_metrics`](https://madsyair.github.io/accuracylevel/reference/robust_metrics.md):

  MedAE, Huber, trimmed MSE, etc.

- [`compare_all_metrics`](https://madsyair.github.io/accuracylevel/reference/compare_all_metrics.md):

  Side-by-side comparison.

## References

Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
method for robust evaluation in predictive analytics. *Decision
Analytics Journal*, 18, 100661.
[doi:10.1016/j.dajour.2025.100661](https://doi.org/10.1016/j.dajour.2025.100661)

## See also

Useful links:

- <https://github.com/madsyair/accuracylevel>

- Report bugs at <https://github.com/madsyair/accuracylevel/issues>

## Author

**Maintainer**: Achmad Syahrul Choir <madsyair@stis.ac.id>

Authors:

- Achmad Syahrul Choir <madsyair@stis.ac.id>

- Mety Agustini <mety.agustini@bps.go.id>

- Kartika Fithriasari <kartika_f@its.ac.id>

- Dedy Dwi Prastyo <dedy.prastyo@its.ac.id>
