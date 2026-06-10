# Replicating Agustini et al. (2026) with accuracylevel

This vignette reproduces the main results of

> Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An
> accuracy-level method for robust evaluation in predictive analytics.
> *Decision Analytics Journal*, 18, 100661.
> <doi:10.1016/j.dajour.2025.100661>

It covers the **simple case** (Table 4–6), the
**regression-with-outliers** simulation, and the **time-series** case,
plus the integration helpers for `caret`, `tidymodels`, and `forecast`.
The **imputation** case study is intentionally omitted: it relies on
confidential firm-level microdata from BPS-Statistics Indonesia that
cannot be redistributed.

### A note on data

The package ships **no datasets**. The article’s data come from public
sources that are referenced by link only:

- simple linear regression and candy-production series on Kaggle (the
  candy series originates from FRED series `IPG3113N`, public domain);
- firm turnover microdata from BPS-Statistics Indonesia (confidential,
  not redistributable).

To keep this vignette fully reproducible and free of downloads, the
regression and time-series sections below use **small simulated datasets
generated inline** with a fixed seed. Code for downloading the real
public series is shown but not executed.

``` r

library(accuracylevel)
```

## 1. Simple case (Table 4–6)

The ten observations of Table 4 are reproduced exactly. Model 1 is the
baseline and the threshold uses the second quartile (Q2) of the error,
where the APE is closest to 0.10.

``` r

actual <- c(7.00, 6.03, 2.02, 5.10, 9.00, 1.00, 3.00, 4.38, 1.00, 8.07)
model1 <- c(6.05, 5.02, 1.32, 5.15, 8.00, 2.20, 2.70, 3.48, 1.00, 7.56)
model2 <- c(8.10, 7.04, 2.12, 5.20, 9.10, 1.00, 3.08, 4.40, 1.00, 6.15)
model3 <- c(7.01, 6.04, 2.09, 5.11, 9.01, 5.10, 3.01, 4.39, 1.00, 8.10)
```

#### Conventional and robust metrics (Table 5)

``` r

conv <- rbind(
  Model1 = conventional_metrics(actual, model1),
  Model2 = conventional_metrics(actual, model2),
  Model3 = conventional_metrics(actual, model3)
)
round(conv, 4)
#>        R_squared   RMSE  NRMSE   MAE    MAPE   SMAPE
#> Model1    0.9194 0.7756 0.1664 0.662 23.3934 20.2449
#> Model2    0.9202 0.7716 0.1656 0.443  6.7401  6.7994
#> Model3    0.7746 1.2968 0.2783 0.426 41.5015 13.9380

rob <- rbind(
  Model1 = robust_metrics(actual, model1),
  Model2 = robust_metrics(actual, model2),
  Model3 = robust_metrics(actual, model3)
)
round(rob, 4)
#>        MedAE   TMSE Huber_Loss Quantile_Loss
#> Model1  0.80 0.5719     0.2988        0.3310
#> Model2  0.10 0.2834     0.2548        0.2215
#> Model3  0.01 0.0008     0.3603        0.2130
```

#### Accuracy-level metrics (Table 6)

``` r

thresh <- calculate_threshold(actual, model1, error_type = "ape", quartile = 2)
thresh
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

al1 <- accuracy_level(actual, model1, threshold = thresh)
al2 <- accuracy_level(actual, model2, threshold = thresh)
al3 <- accuracy_level(actual, model3, threshold = thresh)

al1$metrics
#>   Level CSE CAE CAPE SCAPE
#> 1    L1  40  40   40    40
#> 2    L2  30  60   40    40
#> 3    L3  30   0   10    10
#> 4    L4   0   0   10    10
al2$metrics
#>   Level CSE CAE CAPE SCAPE
#> 1    L1  70  70   70    70
#> 2    L2   0  20   20    20
#> 3    L3  20  10   10    10
#> 4    L4  10   0    0     0
al3$metrics
#>   Level CSE CAE CAPE SCAPE
#> 1    L1  90  90   90    90
#> 2    L2   0   0    0     0
#> 3    L3   0   0    0     0
#> 4    L4  10  10   10    10
```

These match Table 6 of the paper exactly: Model 3 reaches 90% at Level 1
for every metric, while conventional metrics favour Model 2.

``` r

res <- compare_models(
  Model1 = list(actual = actual, predicted = model1),
  Model2 = list(actual = actual, predicted = model2),
  Model3 = list(actual = actual, predicted = model3),
  metric = "cape", threshold = thresh
)
res$optimal_model
#> [1] "Model3"
res$comparison[, c("Model", "L1", "L2", "L3", "L4")]
#>    Model L1 L2 L3 L4
#> 1 Model1 40 40 10 10
#> 2 Model2 70 20 10  0
#> 3 Model3 90  0  0 10
```

## 2. Regression with outliers

The article injects outliers into a clean regression and shows that the
proposed metrics degrade gradually, unlike RMSE/MAPE. Here we mimic that
with a small simulated dataset.

``` r

set.seed(2026)
n <- 200
x <- runif(n, 0, 100)
y <- 1.5 * x + rnorm(n, 0, 3)            # clean response
pred_clean <- 1.5 * x                    # model prediction

# 5% outliers injected into the response
y_out <- y
idx <- sample(n, size = 0.05 * n)
y_out[idx] <- y_out[idx] + 80

baseline <- calculate_threshold(y, pred_clean, error_type = "ape", quartile = 3)

clean <- conventional_metrics(y, pred_clean)
dirty <- conventional_metrics(y_out, pred_clean)
rbind(clean = round(clean, 3), with_outliers = round(dirty, 3))
#>               R_squared  RMSE NRMSE   MAE   MAPE  SMAPE
#> clean             0.996  2.77 0.040 2.220 11.495 10.756
#> with_outliers     0.853 17.99 0.248 6.078 14.044 14.654
```

Conventional metrics (especially MAPE/RMSE) jump sharply. The proposed
Level-1 accuracy, evaluated against a fixed baseline threshold, moves
far less:

``` r

al_clean <- accuracy_level(y,     pred_clean, threshold = baseline)
al_dirty <- accuracy_level(y_out, pred_clean, threshold = baseline)

data.frame(
  scenario = c("clean", "with_outliers"),
  CSE_L1   = c(al_clean$metrics$CSE[1],  al_dirty$metrics$CSE[1]),
  CAPE_L1  = c(al_clean$metrics$CAPE[1], al_dirty$metrics$CAPE[1])
)
#>        scenario CSE_L1 CAPE_L1
#> 1         clean   74.5    74.5
#> 2 with_outliers   71.5    71.0
```

## 3. Time-series case

The paper forecasts U.S. candy production (FRED `IPG3113N`). That series
is public; you could load it directly:

``` r

# Public source (not run during vignette build):
# https://www.kaggle.com/code/goldens/candy-production-time-series-analysis
candy <- read.csv("candy_production.csv")
```

For a self-contained demonstration we simulate a seasonal series and
compare two naive forecasts.

``` r

set.seed(1)
m <- 48
trend <- seq(80, 120, length.out = m)
season <- 10 * sin(2 * pi * (1:m) / 12)
candy <- trend + season + rnorm(m, 0, 3)

fc_seasonal <- c(candy[1:12], candy[1:(m - 12)])    # seasonal-naive-like
fc_mean     <- rep(mean(candy), m)                   # mean forecast

base_ts <- calculate_threshold(candy, fc_seasonal, error_type = "ape", quartile = 2)

data.frame(
  model   = c("seasonal", "mean"),
  CSE_L1  = c(accuracy_level(candy, fc_seasonal, threshold = base_ts)$metrics$CSE[1],
              accuracy_level(candy, fc_mean,     threshold = base_ts)$metrics$CSE[1])
)
#>      model   CSE_L1
#> 1 seasonal 47.91667
#> 2     mean 43.75000
```

## 4. Framework integration

The integration helpers require optional packages; the chunks below run
only when those packages are installed.

#### caret

``` r

library(caret)
#> Loading required package: ggplot2
#> Loading required package: lattice
#> 
#> Attaching package: 'caret'
#> The following object is masked from 'package:accuracylevel':
#> 
#>     compare_models
dat <- data.frame(y = y, x = x)
ctrl <- trainControl(method = "cv", number = 3,
                     summaryFunction = caret_summary())
fit <- train(y ~ x, data = dat, method = "lm",
             trControl = ctrl, metric = "CSE_L1", maximize = TRUE)
fit$results[, c("RMSE", "CSE_L1", "CAE_L1")]
#>       RMSE   CSE_L1   CAE_L1
#> 1 2.747379 74.49872 74.49872
```

#### tidymodels / yardstick

``` r

library(yardstick)
#> 
#> Attaching package: 'yardstick'
#> The following objects are masked from 'package:caret':
#> 
#>     precision, recall, sensitivity, specificity
df <- data.frame(truth = actual, estimate = model3)
accuracy_level_metrics(df, truth, estimate)
#> # A tibble: 16 × 3
#>    .metric  .estimator .estimate
#>    <chr>    <chr>          <dbl>
#>  1 cse_l1   standard          70
#>  2 cse_l2   standard          10
#>  3 cse_l3   standard           0
#>  4 cse_l4   standard          20
#>  5 cae_l1   standard          70
#>  6 cae_l2   standard          10
#>  7 cae_l3   standard          10
#>  8 cae_l4   standard          10
#>  9 cape_l1  standard          70
#> 10 cape_l2  standard          10
#> 11 cape_l3  standard           0
#> 12 cape_l4  standard          20
#> 13 scape_l1 standard          70
#> 14 scape_l2 standard          10
#> 15 scape_l3 standard           0
#> 16 scape_l4 standard          20

al_set <- al_metric_set(include_traditional = TRUE)
al_set(df, truth = truth, estimate = estimate)
#> # A tibble: 7 × 3
#>   .metric  .estimator .estimate
#>   <chr>    <chr>          <dbl>
#> 1 cse_l1   standard      70    
#> 2 cae_l1   standard      70    
#> 3 cape_l1  standard      70    
#> 4 scape_l1 standard      70    
#> 5 rmse     standard       1.30 
#> 6 mae      standard       0.426
#> 7 rsq      standard       0.799
```

#### forecast

``` r

library(forecast)
#> 
#> Attaching package: 'forecast'
#> The following object is masked from 'package:yardstick':
#> 
#>     accuracy
train_ts <- ts(candy[1:36], frequency = 12)
fc <- forecast(ets(train_ts), h = 12)
al_forecast_accuracy(fc, candy[37:48])$metrics
#>   Level       CSE      CAE     CAPE    SCAPE
#> 1    L1 66.666667 66.66667 66.66667 66.66667
#> 2    L2 25.000000 33.33333 33.33333 33.33333
#> 3    L3  8.333333  0.00000  0.00000  0.00000
#> 4    L4  0.000000  0.00000  0.00000  0.00000
```

## Session info

``` r

sessionInfo()
#> R version 4.6.0 (2026-04-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.4 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] forecast_9.0.2      yardstick_1.4.0     caret_7.0-1        
#> [4] lattice_0.22-9      ggplot2_4.0.3       accuracylevel_0.1.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] tidyselect_1.2.1     timeDate_4052.112    dplyr_1.2.1         
#>  [4] farver_2.1.2         S7_0.2.2             fastmap_1.2.0       
#>  [7] pROC_1.19.0.1        digest_0.6.39        rpart_4.1.27        
#> [10] timechange_0.4.0     lifecycle_1.0.5      survival_3.8-6      
#> [13] magrittr_2.0.5       compiler_4.6.0       rlang_1.2.0         
#> [16] sass_0.4.10          tools_4.6.0          utf8_1.2.6          
#> [19] yaml_2.3.12          data.table_1.18.4    knitr_1.51          
#> [22] plyr_1.8.9           RColorBrewer_1.1-3   withr_3.0.2         
#> [25] purrr_1.2.2          desc_1.4.3           nnet_7.3-20         
#> [28] grid_4.6.0           stats4_4.6.0         colorspace_2.1-2    
#> [31] future_1.70.0        globals_0.19.1       scales_1.4.0        
#> [34] iterators_1.0.14     MASS_7.3-65          cli_3.6.6           
#> [37] rmarkdown_2.31       ragg_1.5.2           generics_0.1.4      
#> [40] otel_0.2.0           future.apply_1.20.2  reshape2_1.4.5      
#> [43] cachem_1.1.0         stringr_1.6.0        splines_4.6.0       
#> [46] parallel_4.6.0       urca_1.3-4           vctrs_0.7.3         
#> [49] hardhat_1.4.3        Matrix_1.7-5         jsonlite_2.0.0      
#> [52] listenv_0.10.1       systemfonts_1.3.2    foreach_1.5.2       
#> [55] gower_1.0.2          jquerylib_0.1.4      recipes_1.3.3       
#> [58] glue_1.8.1           parallelly_1.47.0    pkgdown_2.2.0       
#> [61] codetools_0.2-20     lubridate_1.9.5      stringi_1.8.7       
#> [64] gtable_0.3.6         tibble_3.3.1         pillar_1.11.1       
#> [67] htmltools_0.5.9      ipred_0.9-15         lava_1.9.1          
#> [70] R6_2.6.1             textshaping_1.0.5    evaluate_1.0.5      
#> [73] fracdiff_1.5-4       bslib_0.11.0         class_7.3-23        
#> [76] Rcpp_1.1.1-1.1       nlme_3.1-169         prodlim_2026.03.11  
#> [79] xfun_0.58            fs_2.1.0             zoo_1.8-15          
#> [82] ModelMetrics_1.2.2.2 pkgconfig_2.0.3
```
