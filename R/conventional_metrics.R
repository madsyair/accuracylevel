# Conventional and Robust Metrics

#' Calculate Conventional Metrics
#'
#' @description Compute commonly used evaluation metrics including
#'   R-squared, RMSE, NRMSE, MAE, MAPE, and SMAPE.
#'
#' @param actual Numeric vector of actual (observed) values.
#' @param predicted Numeric vector of predicted values.
#' @param na.rm Logical. If \code{TRUE}, remove \code{NA} pairs before
#'   computing. Default is \code{FALSE}.
#'
#' @return A named numeric vector with six elements.
#'
#' @details
#' \code{NRMSE} is normalised by the mean of \code{actual} (returned as
#' \code{NA} when that mean is zero). \code{R_squared} is the usual
#' \eqn{1 - SS_{res}/SS_{tot}} and may be negative for models worse than the
#' mean (unlike the 0--1 range quoted in Table 1 of the paper). \code{MAPE}
#' and \code{SMAPE} are returned on the percentage scale and ignore
#' non-finite per-observation terms (e.g. division by a zero actual value).
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' conventional_metrics(actual, predicted)
#'
#' @export
conventional_metrics <- function(actual, predicted, na.rm = FALSE) {
  vecs <- .prepare_inputs(actual, predicted, na.rm)
  a <- vecs$actual
  p <- vecs$predicted

  n <- length(a)
  errors     <- a - p
  mean_a     <- mean(a)

  ss_res  <- sum(errors^2)
  ss_tot  <- sum((a - mean_a)^2)
  rsq     <- if (ss_tot > 0) 1 - ss_res / ss_tot else NA_real_

  rmse  <- sqrt(mean(errors^2))
  nrmse <- if (mean_a != 0) rmse / mean_a else NA_real_
  mae   <- mean(abs(errors))

  ape_v  <- abs(errors / a)
  mape   <- mean(ape_v[is.finite(ape_v)]) * 100

  sape_v <- abs(errors) / ((abs(a) + abs(p)) / 2)
  smape  <- mean(sape_v[is.finite(sape_v)]) * 100

  c(R_squared = rsq, RMSE = rmse, NRMSE = nrmse,
    MAE = mae, MAPE = mape, SMAPE = smape)
}

#' Calculate Robust Metrics
#'
#' @description Compute robust evaluation metrics including Median
#'   Absolute Error, Trimmed Mean Squared Error, Huber Loss, and
#'   Quantile Loss.
#'
#' @param actual Numeric vector of actual (observed) values.
#' @param predicted Numeric vector of predicted values.
#' @param trim_percent Proportion to trim for TMSE (default 0.1).
#' @param huber_delta Delta parameter for Huber loss (default 1).
#' @param tau Quantile for quantile loss (default 0.5 for median).
#' @param na.rm Logical. Default is \code{FALSE}.
#'
#' @return A named numeric vector with four elements.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50, 1000)
#' predicted <- c(11, 19, 32, 38, 51, 60)
#' robust_metrics(actual, predicted)
#'
#' @export
robust_metrics <- function(actual, predicted, trim_percent = 0.1,
                           huber_delta = 1, tau = 0.5, na.rm = FALSE) {
  vecs <- .prepare_inputs(actual, predicted, na.rm)
  errors <- vecs$actual - vecs$predicted

  medae <- stats::median(abs(errors))
  tmse  <- .trimmed_mse(vecs$actual, vecs$predicted, trim_percent)
  huber <- .huber_loss(errors, huber_delta)
  ql    <- .quantile_loss(errors, tau)

  c(MedAE = medae, TMSE = tmse, Huber_Loss = huber, Quantile_Loss = ql)
}

#' Compare All Metric Types
#'
#' @description Comprehensive comparison of conventional, robust, and
#'   accuracy-level metrics.
#'
#' @param actual Numeric vector of actual values.
#' @param predicted Numeric vector of predicted values.
#' @param threshold Threshold object for accuracy-level metrics.
#'
#' @return A list of class \code{"metrics_comparison"} with
#'   \code{conventional}, \code{robust}, \code{accuracy_level},
#'   and \code{summary} elements.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
#' predicted <- c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98)
#' result <- compare_all_metrics(actual, predicted)
#' print(result)
#'
#' @export
compare_all_metrics <- function(actual, predicted, threshold = NULL) {
  conv   <- conventional_metrics(actual, predicted)
  robust <- robust_metrics(actual, predicted)
  al     <- accuracy_level(actual, predicted, threshold)

  result <- list(
    conventional  = conv,
    robust        = robust,
    accuracy_level = al,
    summary       = .create_comparison_summary(conv, robust, al)
  )
  class(result) <- c("metrics_comparison", "list")
  result
}

#' @export
print.metrics_comparison <- function(x, ...) {
  cat("Metrics Comparison\n")
  cat("==================\n\n")

  cat("Conventional Metrics:\n")
  print(data.frame(Metric = names(x$conventional),
                   Value  = round(x$conventional, 4)),
        row.names = FALSE)

  cat("\nRobust Metrics:\n")
  print(data.frame(Metric = names(x$robust),
                   Value  = round(x$robust, 4)),
        row.names = FALSE)

  cat("\nAccuracy-Level Metrics (L1 %):\n")
  m <- x$accuracy_level$metrics
  cat("  CSE:  ", round(m$CSE[1],   2), "\n")
  cat("  CAE:  ", round(m$CAE[1],   2), "\n")
  cat("  CAPE: ", round(m$CAPE[1],  2), "\n")
  cat("  SCAPE:", round(m$SCAPE[1], 2), "\n")
  invisible(x)
}

# ---- internals ----

#' @noRd
.trimmed_mse <- function(actual, predicted, trim_percent = 0.1) {
  n <- length(actual)
  k <- floor(trim_percent * n)
  if (2L * k >= n) return(NA_real_)
  se <- sort((actual - predicted)^2)
  mean(se[(k + 1L):(n - k)])
}

#' @noRd
.huber_loss <- function(errors, delta = 1) {
  ae <- abs(errors)
  mean(ifelse(ae <= delta, 0.5 * errors^2,
              delta * (ae - 0.5 * delta)))
}

#' @noRd
.quantile_loss <- function(errors, tau = 0.5) {
  mean(ifelse(errors >= 0, tau * errors, (tau - 1) * errors))
}

#' @noRd
.create_comparison_summary <- function(conv, robust, al) {
  data.frame(
    Category = c(rep("Conventional", length(conv)),
                 rep("Robust", length(robust)),
                 rep("Accuracy-Level L1", 4),
                 rep("Accuracy-Level Optimal", 4)),
    Metric = c(names(conv), names(robust),
               c("CSE", "CAE", "CAPE", "SCAPE"),
               c("CSE_Opt", "CAE_Opt", "CAPE_Opt", "SCAPE_Opt")),
    Value = c(as.numeric(conv), as.numeric(robust),
              al$metrics$CSE[1], al$metrics$CAE[1],
              al$metrics$CAPE[1], al$metrics$SCAPE[1],
              al$metrics$CSE[1] + al$metrics$CSE[2],
              al$metrics$CAE[1] + al$metrics$CAE[2],
              al$metrics$CAPE[1] + al$metrics$CAPE[2],
              al$metrics$SCAPE[1] + al$metrics$SCAPE[2]),
    stringsAsFactors = FALSE
  )
}
