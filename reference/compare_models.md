# Compare Multiple Models

Compare multiple prediction models using accuracy-level metrics and
identify the optimal one following the model-selection procedure in
Figure 3 of Agustini et al. (2026).

## Usage

``` r
compare_models(
  ...,
  metric = c("cse", "cae", "cape", "scape"),
  threshold = NULL
)
```

## Arguments

- ...:

  Named arguments, each a list with `actual` and `predicted` elements.

- metric:

  Metric for comparison. Default is `"cse"`.

- threshold:

  Shared `al_threshold` object. When `NULL` (default), the *first* model
  is used as the baseline.

## Value

A list with `optimal_model`, `comparison` table (accuracy and mean error
per level), `metric_used`, and `full_results`.

## Details

The optimal model is selected by the Figure 3 algorithm:

1.  Compare the Level 1 accuracy across models; the model with the
    highest value is selected.

2.  If two or more models tie on Level 1 accuracy, the tie is broken
    using the mean error (ME) of the corresponding level (lower ME is
    better).

3.  If the ME values are also equal, the comparison proceeds to the next
    accuracy level, repeating until the optimal model is identified.

Earlier releases used the simpler rule of ranking by Level 1 then Level
2 accuracy; this version implements the full ME-based tie-break.

## Examples

``` r
actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
m1 <- list(actual = actual,
           predicted = c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56))
m3 <- list(actual = actual,
           predicted = c(7.01, 6.04, 2.09, 5.11, 9.01, 5.1, 3.01, 4.39, 1, 8.1))

res <- compare_models(Model1 = m1, Model3 = m3, metric = "cape")
print(res$comparison)
#>    Model L1 L2 L3 L4       ME_L1     ME_L2     ME_L3 ME_L4
#> 1 Model1 40 40 10 10 0.043250237 0.1549502 0.3465347   1.2
#> 2 Model3 90  0  0 10 0.005571802        NA        NA   4.1
res$optimal_model
#> [1] "Model3"
```
