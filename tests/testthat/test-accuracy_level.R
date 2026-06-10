# ---- structure ----

test_that("accuracy_level returns correct structure", {
  actual    <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
  predicted <- c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98)

  result <- accuracy_level(actual, predicted)

  expect_s3_class(result, "accuracy_level")
  expect_true(all(c("metrics", "mean_errors", "threshold", "thresholds_all",
                     "n_obs", "counts") %in% names(result)))
})

test_that("metrics sum to 100%", {
  actual    <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
  predicted <- c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98)

  result <- accuracy_level(actual, predicted)
  for (col in c("CSE", "CAE", "CAPE", "SCAPE")) {
    expect_equal(sum(result$metrics[[col]]), 100, tolerance = 1e-10)
  }
})

test_that("metrics are between 0 and 100", {
  result <- accuracy_level(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51))
  for (col in c("CSE", "CAE", "CAPE", "SCAPE")) {
    expect_true(all(result$metrics[[col]] >= 0))
    expect_true(all(result$metrics[[col]] <= 100))
  }
})

test_that("count totals equal n_obs", {
  result <- accuracy_level(c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100),
                           c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98))
  for (col in c("CSE", "CAE", "CAPE", "SCAPE")) {
    expect_equal(sum(result$counts[[col]]), result$n_obs)
  }
})

# ---- CRITICAL BUG FIX: perfect predictions ----

test_that("perfect predictions yield 100% L1", {
  actual    <- c(10, 20, 30, 40, 50)
  predicted <- actual

  result <- accuracy_level(actual, predicted)

  expect_equal(result$metrics$CSE[1],   100)
  expect_equal(result$metrics$CAE[1],   100)
  expect_equal(result$metrics$CAPE[1],  100)
  expect_equal(result$metrics$SCAPE[1], 100)

  # L4 must be 0

  expect_equal(result$metrics$CSE[4],   0)
  expect_equal(result$metrics$CAE[4],   0)
  expect_equal(result$metrics$CAPE[4],  0)
  expect_equal(result$metrics$SCAPE[4], 0)
})

# ---- CRITICAL: baseline threshold derivation ----

test_that("baseline thresholds are NOT recalculated from current model", {
  actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
  m1     <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)
  m3     <- c(7.01, 6.04, 2.09, 5.11, 9.01, 5.1, 3.01, 4.39, 1, 8.1)

  thresh_m1 <- calculate_threshold(actual, m1, quartile = 2)
  result3   <- accuracy_level(actual, m3, threshold = thresh_m1)

  expect_equal(result3$thresholds_all$se$threshold,
               thresh_m1$baseline_quartiles$se)
  expect_equal(result3$thresholds_all$ae$threshold,
               thresh_m1$baseline_quartiles$ae)
  expect_equal(result3$thresholds_all$ape$threshold,
               thresh_m1$baseline_quartiles$ape)
})

# ---- custom threshold ----

test_that("accuracy_level works with custom threshold", {
  actual    <- c(10, 20, 30, 40, 50)
  predicted <- c(11, 19, 32, 38, 51)

  ba <- c(5, 15, 25, 35, 45)
  bp <- c(6, 14, 26, 34, 46)
  thresh <- calculate_threshold(ba, bp)

  result <- accuracy_level(actual, predicted, threshold = thresh)
  expect_s3_class(result, "accuracy_level")
})

# ---- S3 methods ----

test_that("print and summary methods work", {
  result <- accuracy_level(c(10, 20, 30), c(11, 19, 28))
  expect_output(print(result), "Accuracy-Level Metrics")
  expect_output(print(result), "Observations:")

  summ <- summary(result)
  expect_s3_class(summ, "accuracy_level_summary")
  expect_true("optimal" %in% names(summ))
})

# ---- NA handling ----

# ---- Paper Table 6: Full verification for all three models ----

test_that("Paper Table 6 Model 1 matches exactly", {
  actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
  m1     <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)
  thresh <- calculate_threshold(actual, m1, quartile = 2)
  r1     <- accuracy_level(actual, m1, threshold = thresh)

  expect_equal(r1$metrics$CSE,   c(40, 30, 30, 0))
  expect_equal(r1$metrics$CAE,   c(40, 60, 0, 0))
  expect_equal(r1$metrics$CAPE,  c(40, 40, 10, 10))
  expect_equal(r1$metrics$SCAPE, c(40, 40, 10, 10))
})

test_that("Paper Table 6 Model 2 matches exactly", {
  actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
  m1     <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)
  m2     <- c(8.10, 7.04, 2.12, 5.20, 9.10, 1.00, 3.08, 4.40, 1.00, 6.15)
  thresh <- calculate_threshold(actual, m1, quartile = 2)
  r2     <- accuracy_level(actual, m2, threshold = thresh)

  expect_equal(r2$metrics$CSE,   c(70, 0, 20, 10))
  expect_equal(r2$metrics$CAE,   c(70, 20, 10, 0))
  expect_equal(r2$metrics$CAPE,  c(70, 20, 10, 0))
  expect_equal(r2$metrics$SCAPE, c(70, 20, 10, 0))
})

test_that("Paper Table 6 Model 3 matches exactly", {
  actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
  m1     <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)
  m3     <- c(7.01, 6.04, 2.09, 5.11, 9.01, 5.1, 3.01, 4.39, 1, 8.1)
  thresh <- calculate_threshold(actual, m1, quartile = 2)
  r3     <- accuracy_level(actual, m3, threshold = thresh)

  expect_equal(r3$metrics$CSE,   c(90, 0, 0, 10))
  expect_equal(r3$metrics$CAE,   c(90, 0, 0, 10))
  expect_equal(r3$metrics$CAPE,  c(90, 0, 0, 10))
  expect_equal(r3$metrics$SCAPE, c(90, 0, 0, 10))
})

# ---- NA handling ----

test_that("accuracy_level errors on NA by default", {
  expect_error(accuracy_level(c(10, NA, 30), c(11, 19, 28)))
})

test_that("accuracy_level handles NA with na.rm = TRUE", {
  result <- accuracy_level(c(10, NA, 30), c(11, 19, NA), na.rm = TRUE)
  expect_equal(result$n_obs, 1)
})
