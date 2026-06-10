test_that("conventional_metrics returns all expected metrics", {
  result <- conventional_metrics(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51))
  expect_named(result, c("R_squared", "RMSE", "NRMSE", "MAE", "MAPE", "SMAPE"))
})

test_that("robust_metrics returns all expected metrics", {
  result <- robust_metrics(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51))
  expect_named(result, c("MedAE", "TMSE", "Huber_Loss", "Quantile_Loss"))
})

test_that("compare_all_metrics returns complete comparison", {
  result <- compare_all_metrics(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51))
  expect_s3_class(result, "metrics_comparison")
  expect_true(all(c("conventional", "robust", "accuracy_level") %in% names(result)))
})

test_that("RMSE and MAE are correct", {
  a <- c(10, 20, 30)
  p <- c(12, 18, 33)
  result <- conventional_metrics(a, p)
  expect_equal(result["RMSE"], c(RMSE = sqrt(mean((a - p)^2))))
  expect_equal(result["MAE"],  c(MAE = mean(abs(a - p))))
})

test_that("robust metrics are more stable with outliers", {
  a_clean   <- c(10, 20, 30, 40, 50)
  a_outlier <- c(10, 20, 30, 40, 500)
  p <- c(11, 19, 32, 38, 51)

  rmse_change <- abs(conventional_metrics(a_outlier, p)["RMSE"] -
                     conventional_metrics(a_clean, p)["RMSE"]) /
                 conventional_metrics(a_clean, p)["RMSE"]

  medae_change <- abs(robust_metrics(a_outlier, p)["MedAE"] -
                      robust_metrics(a_clean, p)["MedAE"]) /
                  robust_metrics(a_clean, p)["MedAE"]

  expect_true(rmse_change > medae_change)
})
