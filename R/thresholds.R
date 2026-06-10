# Threshold calculation functions for accuracy-level metrics

#' Calculate Error Thresholds from a Baseline Model
#'
#' @description Calculate error threshold levels based on a baseline model's
#'   error distribution. The threshold is determined using quartiles of the
#'   specified error type, following the procedure in Figure 2 of
#'   Agustini et al. (2026).
#'
#'   Quartiles are computed using the inverse empirical CDF (R's
#'   \code{type = 1}), consistent with the paper.
#'
#' @param actual Numeric vector of actual (observed) values from the
#'   baseline model.
#' @param predicted Numeric vector of predicted values from the baseline
#'   model.
#' @param error_type Character string specifying the error type used to
#'   select the quartile. One of \code{"ape"} (default, absolute percentage
#'   error), \code{"sape"} (symmetric APE), \code{"se"} (squared error),
#'   or \code{"ae"} (absolute error).
#' @param quartile Integer (1, 2, or 3) specifying which quartile to use.
#'   Default is 2 (median). The recommended approach from the paper is to
#'   select the quartile where the APE value is close to 0.1 (10 percent error).
#' @param multipliers Numeric vector of length 2 specifying the multipliers
#'   for level boundaries. Default is \code{c(2, 5)}, creating levels
#'   L1: error < T, L2: T <= error < 2T, L3: 2T <= error < 5T,
#'   L4: error >= 5T.
#'
#' @return A list of class \code{"al_threshold"} with elements:
#'   \code{threshold} (the base threshold value T),
#'   \code{levels} (a list with L1--L4 boundary pairs),
#'   \code{error_type} (the error type used),
#'   \code{quartile} (the quartile used),
#'   \code{multipliers} (the multiplier values), and
#'   \code{baseline_quartiles} (a named list with the selected quartile
#'   value for every error type: se, ae, ape, sape -- this is the key
#'   element that lets \code{\link{accuracy_level}} derive thresholds for
#'   all four metrics from a single baseline model).
#'
#' @examples
#' # --- Paper Table 4: simple case, Model 1 as baseline ---
#' actual  <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
#' model1  <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)
#'
#' # Q2 of APE ~ 0.1111, close to the target 0.10
#' thresh <- calculate_threshold(actual, model1, quartile = 2)
#' print(thresh)
#'
#' # Stricter thresholds via Q1
#' thresh_q1 <- calculate_threshold(actual, model1, quartile = 1)
#'
#' @seealso \code{\link{accuracy_level}}, \code{\link{auto_threshold}}
#'
#' @references
#' Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
#' method for robust evaluation in predictive analytics. \emph{Decision
#' Analytics Journal}, 18, 100661. \doi{10.1016/j.dajour.2025.100661}
#'
#' @export
calculate_threshold <- function(actual,
                                predicted,
                                error_type = c("ape", "sape", "se", "ae"),
                                quartile = 2,
                                multipliers = c(2, 5)) {

  error_type <- match.arg(error_type)

  # --- validate quartile ---
  if (!quartile %in% c(1L, 2L, 3L)) {
    stop("'quartile' must be 1, 2, or 3.", call. = FALSE)
  }

  # --- validate multipliers ---
  if (!is.numeric(multipliers) || length(multipliers) != 2L) {
    stop("'multipliers' must be a numeric vector of length 2.", call. = FALSE)
  }
  if (any(multipliers <= 1)) {
    stop("'multipliers' must be greater than 1.", call. = FALSE)
  }
  if (multipliers[1] >= multipliers[2]) {
    stop("First multiplier must be less than second multiplier.", call. = FALSE)
  }

  # --- compute errors for ALL four types ---
  se   <- squared_error(actual, predicted, na.rm = TRUE)
  ae   <- absolute_error(actual, predicted, na.rm = TRUE)
  ape  <- absolute_percentage_error(actual, predicted, na.rm = TRUE)
  sape <- symmetric_absolute_percentage_error(actual, predicted, na.rm = TRUE)

  # --- quartile prob ---
  prob <- c(0.25, 0.50, 0.75)[quartile]

  # --- helper: finite quantile with type = 1 ---
  safe_q <- function(x) {
    xf <- x[is.finite(x)]
    if (length(xf) == 0L) return(NA_real_)
    stats::quantile(xf, probs = prob, names = FALSE, type = 1L)
  }

  # --- compute baseline quartile for each error type ---
  bq <- list(
    se   = safe_q(se),
    ae   = safe_q(ae),
    ape  = safe_q(ape),
    sape = safe_q(sape)
  )

  # --- primary threshold from the requested error_type ---
  threshold <- bq[[error_type]]
  if (is.na(threshold)) {
    stop(
      "All ", error_type, " values are infinite or NaN. ",
      "Cannot compute threshold.",
      call. = FALSE
    )
  }

  # --- level boundaries ---
  levels <- .make_levels(threshold, multipliers)

  result <- list(
    threshold         = threshold,
    levels            = levels,
    error_type        = error_type,
    quartile          = as.integer(quartile),
    multipliers       = multipliers,
    baseline_quartiles = bq
  )

  class(result) <- c("al_threshold", "list")
  result
}

#' Print Method for al_threshold Objects
#'
#' @param x An \code{al_threshold} object.
#' @param ... Additional arguments (ignored).
#'
#' @return Invisibly returns the input object.
#'
#' @export
print.al_threshold <- function(x, ...) {
  cat("Accuracy-Level Threshold\n")
  cat("========================\n")
  cat("Error type:", x$error_type, "\n")
  cat("Quartile: Q", x$quartile, "\n", sep = "")
  cat("Base threshold (T):", format(x$threshold, digits = 4), "\n")
  cat("Multipliers:", paste(x$multipliers, collapse = ", "), "\n\n")

  cat("Level Boundaries (", x$error_type, "):\n", sep = "")
  cat("  L1: error <", format(x$levels$L1[2], digits = 4), "\n")
  cat("  L2:", format(x$levels$L2[1], digits = 4), "<= error <",
      format(x$levels$L2[2], digits = 4), "\n")
  cat("  L3:", format(x$levels$L3[1], digits = 4), "<= error <",
      format(x$levels$L3[2], digits = 4), "\n")
  cat("  L4: error >=", format(x$levels$L4[1], digits = 4), "\n")

  if (!is.null(x$baseline_quartiles)) {
    cat("\nBaseline Q", x$quartile, " for all error types:\n", sep = "")
    bq <- x$baseline_quartiles
    cat("  SE:  ", format(bq$se,   digits = 4), "\n")
    cat("  AE:  ", format(bq$ae,   digits = 4), "\n")
    cat("  APE: ", format(bq$ape,  digits = 4), "\n")
    cat("  sAPE:", format(bq$sape, digits = 4), "\n")
  }
  invisible(x)
}


#' Automatic Threshold Selection
#'
#' @description Automatically select the best quartile for threshold
#'   calculation based on the absolute percentage error approaching a
#'   target value (default 0.1), following the recommendation in
#'   Section 3.4.5 of Agustini et al. (2026).
#'
#' @param actual Numeric vector of actual (observed) values.
#' @param predicted Numeric vector of predicted values.
#' @param target_ape Target APE value for threshold selection. Default is
#'   0.1 (10 percent).
#' @param error_type Error type to calculate threshold for. Default is
#'   \code{"ape"}.
#' @param multipliers Numeric vector of multipliers. Default is
#'   \code{c(2, 5)}.
#'
#' @return An \code{al_threshold} object with automatically selected quartile.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
#' predicted <- c(11, 19, 32, 38, 51, 58, 72, 78, 92, 98)
#' thresh <- auto_threshold(actual, predicted)
#' print(thresh)
#'
#' @export
auto_threshold <- function(actual,
                           predicted,
                           target_ape = 0.1,
                           error_type = "ape",
                           multipliers = c(2, 5)) {

  ape <- absolute_percentage_error(actual, predicted, na.rm = TRUE)
  ape_finite <- ape[is.finite(ape)]

  if (length(ape_finite) == 0L) {
    warning("No finite APE values. Using quartile 2 with sAPE.", call. = FALSE)
    return(calculate_threshold(actual, predicted, error_type = "sape",
                               quartile = 2L, multipliers = multipliers))
  }

  # Compute all three APE quartiles using type = 1
  qs <- stats::quantile(ape_finite, probs = c(0.25, 0.50, 0.75),
                         names = FALSE, type = 1L)
  distances <- abs(qs - target_ape)
  best_quartile <- which.min(distances)

  calculate_threshold(actual, predicted, error_type,
                      quartile = best_quartile, multipliers = multipliers)
}


# ==== Internal helpers ====

#' Build Level Boundaries
#'
#' Handles the special case where T = 0 (perfect predictions) by using a
#' small epsilon so that zero-error observations still fall into L1.
#'
#' @param threshold Numeric. The base threshold T.
#' @param multipliers Numeric vector of length 2. The two multiplier values.
#'
#' @return A list with L1, L2, L3, L4 boundary pairs.
#' @noRd
.make_levels <- function(threshold, multipliers) {
  m1 <- multipliers[1]
  m2 <- multipliers[2]

  # When T == 0 (all predictions are perfect in the baseline), use a tiny
  # epsilon so that exact-zero errors map to L1 (error < eps) and any
  # nonzero error maps to L4.
  if (threshold == 0) {
    eps <- .Machine$double.eps
    list(
      L1 = c(0, eps),
      L2 = c(eps, m1 * eps),
      L3 = c(m1 * eps, m2 * eps),
      L4 = c(m2 * eps, Inf)
    )
  } else {
    list(
      L1 = c(0, threshold),
      L2 = c(threshold, m1 * threshold),
      L3 = c(m1 * threshold, m2 * threshold),
      L4 = c(m2 * threshold, Inf)
    )
  }
}
