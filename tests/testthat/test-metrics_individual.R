test_that("cse returns correct values", {
  actual    <- c(10, 20, 30, 40, 50)
  predicted <- c(11, 19, 32, 38, 51)

  r <- cse(actual, predicted, level = 1)
  expect_type(r, "double")
  expect_length(r, 1)
  expect_true(r >= 0 && r <= 100)
})

test_that("cae returns correct values", {
  r <- cae(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51), level = 1)
  expect_type(r, "double")
  expect_true(r >= 0 && r <= 100)
})

test_that("cape returns correct values", {
  r <- cape(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51), level = 1)
  expect_type(r, "double")
  expect_true(r >= 0 && r <= 100)
})

test_that("scape returns correct values", {
  r <- scape(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51), level = 1)
  expect_type(r, "double")
  expect_true(r >= 0 && r <= 100)
})

test_that("as_decimal works", {
  pct <- cae(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51), as_decimal = FALSE)
  dec <- cae(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51), as_decimal = TRUE)
  expect_equal(pct / 100, dec)
})

test_that("get_all_levels sums to 100", {
  v <- get_all_levels(c(10, 20, 30, 40, 50), c(11, 19, 32, 38, 51), "cae")
  expect_named(v, c("L1", "L2", "L3", "L4"))
  expect_equal(sum(v), 100)
})

test_that("level validation works", {
  expect_error(cse(c(10, 20), c(11, 19), level = 0), "1, 2, 3, or 4")
  expect_error(cse(c(10, 20), c(11, 19), level = 5), "1, 2, 3, or 4")
})

test_that("compare_models uses first model as baseline", {
  m1 <- list(actual = c(10, 20, 30, 40, 50),
             predicted = c(11, 19, 32, 38, 51))
  m2 <- list(actual = c(10, 20, 30, 40, 50),
             predicted = c(15, 25, 35, 45, 55))

  result <- compare_models(Good = m1, Bad = m2, metric = "cae")
  expect_equal(result$optimal_model, "Good")
  expect_true("comparison" %in% names(result))
})

test_that("compare_models requires >= 2 models", {
  expect_error(compare_models(One = list(actual = 1:3, predicted = 1:3)),
               "At least two")
})

test_that("comparison table reports mean errors per level", {
  m1 <- list(actual = c(10, 20, 30, 40, 50),
             predicted = c(11, 19, 32, 38, 51))
  m2 <- list(actual = c(10, 20, 30, 40, 50),
             predicted = c(12, 18, 33, 37, 52))
  result <- compare_models(A = m1, B = m2, metric = "cae")
  expect_true(all(c("ME_L1", "ME_L2", "ME_L3", "ME_L4") %in%
                    names(result$comparison)))
})

test_that("Figure 3 tie-break uses mean error when L1 ties", {
  # Baseline with large errors sets a large absolute-error threshold so that
  # both candidate models fall entirely in Level 1. They then tie on L1
  # accuracy (100%) and the tie must be broken by the lower mean error.
  actual   <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
  baseline <- actual + 5          # AE = 5 for all -> threshold T_ae = 5
  close    <- actual + 1          # AE = 1 (all < 5 -> all L1), smaller ME
  looser   <- actual + 2          # AE = 2 (all < 5 -> all L1), larger ME

  base <- calculate_threshold(actual, baseline, error_type = "ae",
                              quartile = 3)

  res <- compare_models(
    Close  = list(actual = actual, predicted = close),
    Looser = list(actual = actual, predicted = looser),
    metric = "cae", threshold = base
  )
  expect_equal(res$comparison$L1, c(100, 100))     # genuine L1 tie
  expect_equal(res$optimal_model, "Close")          # broken by lower ME_L1
})
