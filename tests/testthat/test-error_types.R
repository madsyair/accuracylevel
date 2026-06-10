test_that("squared_error calculates correctly", {
  expect_equal(squared_error(c(10, 20, 30), c(11, 19, 28)), c(1, 1, 4))
})

test_that("absolute_error calculates correctly", {
  expect_equal(absolute_error(c(10, 20, 30), c(11, 19, 28)), c(1, 1, 2))
})

test_that("absolute_percentage_error calculates correctly", {
  expect_equal(
    absolute_percentage_error(c(10, 20, 30), c(11, 19, 28)),
    c(0.1, 0.05, 2 / 30)
  )
})

test_that("APE returns Inf for zero actual", {
  result <- absolute_percentage_error(c(0, 20), c(1, 19))
  expect_true(is.infinite(result[1]))
  expect_false(is.infinite(result[2]))
})

test_that("sAPE calculates correctly", {
  a <- c(10, 20, 30)
  p <- c(11, 19, 28)
  expected <- abs(a - p) / ((abs(a) + abs(p)) / 2)
  expect_equal(symmetric_absolute_percentage_error(a, p), expected)
})

test_that("error functions validate inputs", {
  expect_error(squared_error("a", c(1, 2)), "numeric")
  expect_error(squared_error(c(1, 2), c(1, 2, 3)), "same length")
  expect_error(squared_error(numeric(0), numeric(0)), "at least one")
})

test_that("na.rm works correctly", {
  a <- c(10, NA, 30)
  p <- c(11, 19, NA)
  expect_error(squared_error(a, p))
  result <- squared_error(a, p, na.rm = TRUE)
  expect_length(result, 1)
  expect_equal(result, 1)
})

test_that("Paper Table 4 Model 1 errors match", {
  actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
  m1     <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)

  se  <- squared_error(actual, m1)
  ae  <- absolute_error(actual, m1)
  ape <- absolute_percentage_error(actual, m1)

  # Paper Table 5 row 1: SE = 0.9025, AE = 0.95
  expect_equal(se[1],  (7 - 6.05)^2, tolerance = 1e-8)
  expect_equal(ae[1],  abs(7 - 6.05), tolerance = 1e-8)
  expect_equal(ape[1], abs(7 - 6.05) / 7, tolerance = 1e-8)
})
