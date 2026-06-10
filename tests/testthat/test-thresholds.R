# ---- structure ----

test_that("calculate_threshold returns correct structure", {
  actual    <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
  predicted <- c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98)

  result <- calculate_threshold(actual, predicted)

  expect_s3_class(result, "al_threshold")
  expect_true("baseline_quartiles" %in% names(result))
  expect_true(all(c("se", "ae", "ape", "sape") %in% names(result$baseline_quartiles)))
})

test_that("calculate_threshold works for all error types", {
  actual    <- c(10, 20, 30, 40, 50)
  predicted <- c(11, 19, 32, 38, 51)

  for (et in c("se", "ae", "ape", "sape")) {
    result <- calculate_threshold(actual, predicted, error_type = et)
    expect_s3_class(result, "al_threshold")
    expect_equal(result$error_type, et)
  }
})

test_that("quartile ordering is monotone", {
  actual    <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
  predicted <- c(15, 25, 35, 45, 55, 65, 75, 85, 95, 105)

  t1 <- calculate_threshold(actual, predicted, quartile = 1)
  t2 <- calculate_threshold(actual, predicted, quartile = 2)
  t3 <- calculate_threshold(actual, predicted, quartile = 3)

  expect_true(t1$threshold <= t2$threshold)
  expect_true(t2$threshold <= t3$threshold)
})

test_that("parameter validation works", {
  a <- c(10, 20, 30)
  p <- c(11, 19, 28)
  expect_error(calculate_threshold(a, p, quartile = 5), "1, 2, or 3")
  expect_error(calculate_threshold(a, p, multipliers = c(1, 2)), "greater than 1")
  expect_error(calculate_threshold(a, p, multipliers = c(5, 2)), "less than")
})

test_that("level boundaries match T * multipliers", {
  a <- c(10, 20, 30, 40, 50)
  p <- c(11, 19, 32, 38, 51)
  result <- calculate_threshold(a, p, multipliers = c(2, 5))
  T_ <- result$threshold

  expect_equal(result$levels$L1, c(0, T_))
  expect_equal(result$levels$L2, c(T_, 2 * T_))
  expect_equal(result$levels$L3, c(2 * T_, 5 * T_))
  expect_equal(result$levels$L4, c(5 * T_, Inf))
})

test_that("print method works", {
  result <- calculate_threshold(c(10, 20, 30), c(11, 19, 28))
  expect_output(print(result), "Accuracy-Level Threshold")
  expect_output(print(result), "Baseline Q")
})

# ---- Paper verification: type=1 quartiles ----

test_that("quantile type=1 matches paper Table 7", {
  actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
  m1     <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)

  thresh <- calculate_threshold(actual, m1, error_type = "ape", quartile = 2)

  # Paper Table 7: APE Q2 = 0.1111
  expect_equal(thresh$threshold, 1 / 9, tolerance = 1e-4)

  # Paper Table 7: SE Q2 = 0.49
  expect_equal(thresh$baseline_quartiles$se, 0.49, tolerance = 1e-4)

  # Paper Table 7: AE Q2 = 0.70
  expect_equal(thresh$baseline_quartiles$ae, 0.70, tolerance = 1e-4)
})

test_that("auto_threshold selects best quartile", {
  actual    <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
  predicted <- c(11, 20, 32, 40, 52, 60, 72, 80, 92, 100)

  result <- auto_threshold(actual, predicted, target_ape = 0.1)
  expect_s3_class(result, "al_threshold")
  expect_true(result$quartile %in% 1:3)
})
