# accuracylevel <img src="man/figures/logo.png" align="right" height="139" alt="accuracylevel logo" />

<!-- badges: start -->
[![R-CMD-check](https://github.com/madsyair/accuracylevel/workflows/R-CMD-check/badge.svg)](https://github.com/madsyair/accuracylevel/actions)
[![CRAN status](https://www.r-pkg.org/badges/version/accuracylevel)](https://CRAN.R-project.org/package=accuracylevel)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.r-project.org/Licenses/GPL-3)
<!-- badges: end -->

## Overview

The **accuracylevel** package implements novel accuracy-level metrics for evaluating continuous data prediction models, as described in [Agustini, Fithriasari, and Prastyo (2026)](https://doi.org/10.1016/j.dajour.2025.100661).

This is the initial release (version 0.1.0).

### Key Features

- **Robust**: Gradual degradation under outlier presence, unlike conventional metrics
- **Consistent**: Same optimal model selection across all four metrics
- **Objective**: Multi-level assessment reveals distribution of prediction quality
- **Comparable**: Standardized 0-100% scale across all metrics and models

### The Four Metrics

| Metric | Description |
|--------|-------------|
| **CSE** | Counted Squared Error |
| **CAE** | Counted Absolute Error |
| **CAPE** | Counted Absolute Percentage Error |
| **SCAPE** | Symmetric Counted Absolute Percentage Error |

Each metric assigns observations to four accuracy levels:
- **L1**: error < T (highest accuracy)
- **L2**: T <= error < 2T
- **L3**: 2T <= error < 5T
- **L4**: error >= 5T (lowest accuracy)

where T is a threshold derived from the baseline model's error distribution.

## Installation

The package is not yet on CRAN. Install the development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("madsyair/accuracylevel")
```

## Quick Start

```r
library(accuracylevel)

# Sample data
actual <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
predicted <- c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98)

# Calculate all accuracy-level metrics
result <- accuracy_level(actual, predicted)
print(result)

# Get individual metrics
cse(actual, predicted, level = 1)  # CSE Level 1
cae(actual, predicted, level = 1)  # CAE Level 1

# Compare with conventional metrics
compare_all_metrics(actual, predicted)
```

## Integration with Popular Frameworks

### caret

```r
library(caret)

ctrl <- trainControl(method = "cv", number = 5,
                     summaryFunction = caret_summary())

model <- train(y ~ ., data = training_data, method = "lm",
               trControl = ctrl, metric = "CAE_L1", maximize = TRUE)
```

### tidymodels

```r
library(tidymodels)

# Single metric
predictions |> cae_l1(truth = outcome, estimate = .pred)

# Or use the metric set
al_metrics <- al_metric_set()
predictions |> al_metrics(truth = outcome, estimate = .pred)
```

### forecast

```r
library(forecast)

fit <- auto.arima(train_ts)
fc  <- forecast(fit, h = 24)
al_forecast_accuracy(fc, test_ts)
```

## Model Comparison

```r
m1 <- list(actual = y, predicted = pred_a)
m2 <- list(actual = y, predicted = pred_b)

result <- compare_models(ModelA = m1, ModelB = m2, metric = "cae")
result$optimal_model
result$comparison
```

## Data Used in the Article

This package does **not** bundle any datasets. The data used in the source
article are obtained from their original providers:

- **Simple linear regression** and **candy production time series**:
  publicly available on Kaggle
  (<https://www.kaggle.com/code/scarfx/simple-liner-regression>,
  <https://www.kaggle.com/code/goldens/candy-production-time-series-analysis>).
  The candy production series originates from the U.S. Federal Reserve
  (FRED series IPG3113N), which is in the public domain.
- **Firm turnover / imputation data**: firm-level microdata from
  BPS-Statistics Indonesia. This is confidential survey microdata and is
  **not** redistributable; it must be requested directly from BPS-Statistics Indonesia. For this reason no imputation dataset is shipped
  with the package, and the package vignette does not reproduce the
  imputation case study.

The package vignette reproduces the article's results using small,
reproducible simulated data generated inline (see
`vignette("replication", package = "accuracylevel")`).

## Why Accuracy-Level Metrics?

| Issue with Conventional Metrics | How Accuracy-Level Addresses It |
|--------------------------------|--------------------------------|
| Sensitive to outliers | Count-based approach is robust |
| Scale-dependent | Standardized 0-100% scale |
| Single summary statistic | Multi-level distribution view |
| Inconsistent optimal selection | Consistent across all four metrics |

## Citation

If you use this package in your research, please cite:

```
Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
method for robust evaluation in predictive analytics. Decision Analytics
Journal, 18, 100661. https://doi.org/10.1016/j.dajour.2025.100661
```

## License

GPL-3 (c) The accuracylevel authors.
