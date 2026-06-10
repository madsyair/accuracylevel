#' Compute Accuracy-Level Metrics
#'
#' @description Calculate accuracy-level metrics (CSE, CAE, CAPE, SCAPE) for
#'   evaluating prediction model performance. These metrics assess the
#'   proportion of observations falling within predefined error threshold
#'   levels, providing a robust and interpretable evaluation on a 0--100\%
#'   scale.
#'
#' @param actual Numeric vector of actual (observed) values.
#' @param predicted Numeric vector of predicted values.
#' @param threshold An \code{al_threshold} object created by
#'   \code{\link{calculate_threshold}} or \code{\link{auto_threshold}}.
#'   When supplied, the baseline quartiles stored inside this object are used
#'   to derive per-error-type thresholds (see Details).
#'   If \code{NULL} (default), thresholds are automatically determined via
#'   \code{\link{auto_threshold}}.
#' @param baseline_actual Numeric vector of actual values from the baseline
#'   model. Used only when \code{threshold} is \code{NULL}.
#' @param baseline_predicted Numeric vector of predicted values from the
#'   baseline model. Used only when \code{threshold} is \code{NULL}.
#' @param na.rm Logical. If \code{TRUE}, remove \code{NA} pairs before
#'   computing. Default is \code{FALSE}.
#'
#' @return An object of class \code{"accuracy_level"} with elements:
#'   \code{metrics} (data frame with accuracy percentages for each level
#'   and metric type),
#'   \code{mean_errors} (data frame with mean errors per level),
#'   \code{threshold} (the primary threshold object used),
#'   \code{thresholds_all} (per-error-type threshold objects),
#'   \code{n_obs} (number of observations), and
#'   \code{counts} (count of observations at each level).
#'
#' @details
#' The accuracy-level method introduces four metrics:
#' \describe{
#'   \item{CSE (Counted Squared Error)}{Proportion of observations within
#'     squared error threshold levels.}
#'   \item{CAE (Counted Absolute Error)}{Proportion of observations within
#'     absolute error threshold levels.}
#'   \item{CAPE (Counted Absolute Percentage Error)}{Proportion of observations
#'     within absolute percentage error threshold levels.}
#'   \item{SCAPE (Symmetric Counted Absolute Percentage Error)}{Proportion of
#'     observations within symmetric absolute percentage error threshold
#'     levels.}
#' }
#'
#' For each metric, four accuracy levels are defined:
#' \itemize{
#'   \item Level 1: \eqn{\varepsilon < T} (highest accuracy)
#'   \item Level 2: \eqn{T \le \varepsilon < 2T}
#'   \item Level 3: \eqn{2T \le \varepsilon < 5T}
#'   \item Level 4: \eqn{\varepsilon \ge 5T} (lowest accuracy)
#' }
#'
#' where T is the base threshold determined from the \strong{baseline} model's
#' error distribution.  Crucially, thresholds for CSE, CAE, CAPE, and SCAPE
#' are each derived from the same quartile of the baseline model's SE, AE,
#' APE, and sAPE respectively (Figure 2 of the paper).
#'
#' Edge cases are handled as follows: observations with a non-finite error
#' (for example APE when \code{actual} is zero, or sAPE when both
#' \code{actual} and \code{predicted} are zero) are assigned to Level 4. When
#' the baseline threshold T equals zero (a perfectly fitting baseline), a
#' machine-epsilon boundary is used so that exact-zero errors fall into
#' Level 1.
#'
#' @references
#' Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
#' method for robust evaluation in predictive analytics. \emph{Decision
#' Analytics Journal}, 18, 100661. \doi{10.1016/j.dajour.2025.100661}
#'
#' @examples
#' # ---- Paper Table 4: Simple case ----
#' actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
#' m1 <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)
#' m3 <- c(7.01, 6.04, 2.09, 5.11, 9.01, 5.1, 3.01, 4.39, 1, 8.1)
#'
#' # Model 1 as baseline, Q2
#' thresh <- calculate_threshold(actual, m1, quartile = 2)
#'
#' # Evaluate Model 3 (paper expects 90% at L1)
#' result <- accuracy_level(actual, m3, threshold = thresh)
#' print(result)
#'
#' @seealso
#' \code{\link{calculate_threshold}}, \code{\link{auto_threshold}},
#' \code{\link{cse}}, \code{\link{cae}}, \code{\link{cape}},
#' \code{\link{scape}}
#'
#' @export
accuracy_level <- function(actual,
                           predicted,
                           threshold = NULL,
                           baseline_actual = NULL,
                           baseline_predicted = NULL,
                           na.rm = FALSE) {

  vecs <- .prepare_inputs(actual, predicted, na.rm)
  actual    <- vecs$actual
  predicted <- vecs$predicted
  n <- length(actual)

  # ---- obtain / build threshold ----
  if (is.null(threshold)) {
    ba <- if (is.null(baseline_actual))    actual    else baseline_actual
    bp <- if (is.null(baseline_predicted)) predicted else baseline_predicted
    threshold <- auto_threshold(ba, bp)
  }

  if (!inherits(threshold, "al_threshold")) {
    stop("'threshold' must be an 'al_threshold' object.", call. = FALSE)
  }

  # ---- compute errors for the current model ----
  se   <- squared_error(actual, predicted)
  ae   <- absolute_error(actual, predicted)
  ape  <- absolute_percentage_error(actual, predicted)
  sape <- symmetric_absolute_percentage_error(actual, predicted)

  # ---- derive per-error-type thresholds from the BASELINE quartiles ----
  bq <- threshold$baseline_quartiles
  mult <- threshold$multipliers

  # If threshold was built before baseline_quartiles existed (defensive)
  if (is.null(bq)) {
    warning(
      "Threshold object lacks 'baseline_quartiles'. ",
      "Thresholds will be derived from the current model's data.",
      call. = FALSE
    )
    bq <- list(
      se   = stats::quantile(se[is.finite(se)],
               probs = c(0.25, 0.50, 0.75)[threshold$quartile],
               names = FALSE, type = 1L),
      ae   = stats::quantile(ae[is.finite(ae)],
               probs = c(0.25, 0.50, 0.75)[threshold$quartile],
               names = FALSE, type = 1L),
      ape  = stats::quantile(ape[is.finite(ape)],
               probs = c(0.25, 0.50, 0.75)[threshold$quartile],
               names = FALSE, type = 1L),
      sape = stats::quantile(sape[is.finite(sape)],
               probs = c(0.25, 0.50, 0.75)[threshold$quartile],
               names = FALSE, type = 1L)
    )
  }

  # Build level boundaries from each baseline quartile
  levels_se   <- .make_levels(bq$se,   mult)
  levels_ae   <- .make_levels(bq$ae,   mult)
  levels_ape  <- .make_levels(bq$ape,  mult)
  levels_sape <- .make_levels(bq$sape, mult)

  # ---- assign observations to levels ----
  cse_res   <- .compute_metric_levels(se,   bq$se,   mult)
  cae_res   <- .compute_metric_levels(ae,   bq$ae,   mult)
  cape_res  <- .compute_metric_levels(ape,  bq$ape,  mult)
  scape_res <- .compute_metric_levels(sape, bq$sape, mult)

  # ---- output tables ----
  metrics <- data.frame(
    Level = paste0("L", 1:4),
    CSE   = cse_res$percentages,
    CAE   = cae_res$percentages,
    CAPE  = cape_res$percentages,
    SCAPE = scape_res$percentages,
    stringsAsFactors = FALSE
  )

  mean_errors <- data.frame(
    Level    = paste0("L", 1:4),
    ME_CSE   = cse_res$mean_errors,
    ME_CAE   = cae_res$mean_errors,
    ME_CAPE  = cape_res$mean_errors,
    ME_SCAPE = scape_res$mean_errors,
    stringsAsFactors = FALSE
  )

  counts <- data.frame(
    Level = paste0("L", 1:4),
    CSE   = cse_res$counts,
    CAE   = cae_res$counts,
    CAPE  = cape_res$counts,
    SCAPE = scape_res$counts,
    stringsAsFactors = FALSE
  )

  thresholds_all <- list(
    se   = list(threshold = bq$se,   levels = levels_se),
    ae   = list(threshold = bq$ae,   levels = levels_ae),
    ape  = list(threshold = bq$ape,  levels = levels_ape),
    sape = list(threshold = bq$sape, levels = levels_sape)
  )

  result <- list(
    metrics          = metrics,
    mean_errors      = mean_errors,
    threshold        = threshold,
    thresholds_all   = thresholds_all,
    n_obs            = n,
    counts           = counts,
    actual           = actual,
    predicted        = predicted,
    errors           = list(se = se, ae = ae, ape = ape, sape = sape),
    level_assignments = list(
      cse   = cse_res$levels,
      cae   = cae_res$levels,
      cape  = cape_res$levels,
      scape = scape_res$levels
    )
  )

  class(result) <- c("accuracy_level", "list")
  result
}


# ==== Internal: level assignment ====

#' Assign observations to accuracy levels and compute percentages
#'
#' Handles T = 0 (perfect baseline) via \code{.make_levels()}, which
#' replaces T with \code{.Machine$double.eps} so that zero errors → L1.
#' Infinite / NaN errors are always assigned to L4.
#'
#' @param errors Numeric vector of errors for the current model.
#' @param threshold Base threshold T (from the baseline model).
#' @param multipliers Pair of multiplier values.
#'
#' @return A list with \code{percentages}, \code{mean_errors},
#'   \code{counts}, and \code{levels}.
#' @noRd
.compute_metric_levels <- function(errors, threshold, multipliers) {
  n  <- length(errors)
  m1 <- multipliers[1]
  m2 <- multipliers[2]

  lvls <- .make_levels(threshold, multipliers)
  T1 <- lvls$L1[2]     # upper bound of L1  (= T or eps if T == 0)
  T2 <- lvls$L2[2]     # upper bound of L2
  T3 <- lvls$L3[2]     # upper bound of L3

  levels <- rep(NA_integer_, n)
  ok <- is.finite(errors)

  levels[ok & errors <  T1] <- 1L
  levels[ok & errors >= T1 & errors < T2] <- 2L
  levels[ok & errors >= T2 & errors < T3] <- 3L
  levels[ok & errors >= T3] <- 4L
  levels[!ok] <- 4L                     # Inf / NaN → worst level

  counts <- vapply(1:4, function(k) sum(levels == k, na.rm = TRUE), integer(1))
  percentages <- (counts / n) * 100

  mean_errors <- vapply(1:4, function(k) {
    idx <- which(levels == k & ok)
    if (length(idx) > 0L) mean(errors[idx]) else NA_real_
  }, double(1))

  list(percentages = percentages,
       mean_errors = mean_errors,
       counts      = counts,
       levels      = levels)
}


# ==== S3 methods ====

#' @export
print.accuracy_level <- function(x, digits = 2, ...) {
  cat("Accuracy-Level Metrics\n")
  cat("======================\n")
  cat("Observations:", x$n_obs, "\n")
  cat("Threshold quartile: Q", x$threshold$quartile, "\n", sep = "")
  cat("Multipliers:", paste(x$threshold$multipliers, collapse = ", "), "\n\n")

  cat("Accuracy by Level (%):\n")
  m <- x$metrics
  m[, -1] <- round(m[, -1], digits)
  print(m, row.names = FALSE)

  cat("\nInterpretation:\n")
  cat("  L1: Highest accuracy (error < T)\n")
  cat("  L4: Lowest accuracy  (error >= 5T)\n")
  cat("  Higher L1 values indicate better model performance.\n")
  invisible(x)
}

#' @export
summary.accuracy_level <- function(object, ...) {
  optimal <- c(
    CSE   = object$metrics$CSE[1]   + object$metrics$CSE[2],
    CAE   = object$metrics$CAE[1]   + object$metrics$CAE[2],
    CAPE  = object$metrics$CAPE[1]  + object$metrics$CAPE[2],
    SCAPE = object$metrics$SCAPE[1] + object$metrics$SCAPE[2]
  )
  result <- list(
    n_obs       = object$n_obs,
    metrics     = object$metrics,
    mean_errors = object$mean_errors,
    optimal     = optimal,
    threshold   = object$threshold
  )
  class(result) <- c("accuracy_level_summary", "list")
  result
}

#' @export
print.accuracy_level_summary <- function(x, digits = 2, ...) {
  cat("Accuracy-Level Metrics Summary\n")
  cat("==============================\n\n")
  cat("Number of observations:", x$n_obs, "\n\n")

  cat("Accuracy by Level (%):\n")
  m <- x$metrics
  m[, -1] <- round(m[, -1], digits)
  print(m, row.names = FALSE)

  cat("\nMean Errors by Level:\n")
  me <- x$mean_errors
  me[, -1] <- round(me[, -1], 4)
  print(me, row.names = FALSE)

  cat("\nOptimal Performance Score (L1 + L2):\n")
  for (nm in names(x$optimal)) {
    cat("  ", nm, ": ", round(x$optimal[nm], digits), "%\n", sep = "")
  }
  invisible(x)
}

#' @export
plot.accuracy_level <- function(x,
                                type = c("bar", "stacked", "comparison"),
                                ...) {
  type <- match.arg(type)
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    .plot_accuracy_ggplot(x, type, ...)
  } else {
    .plot_accuracy_base(x, type, ...)
  }
}

#' @noRd
.plot_accuracy_ggplot <- function(x, type, ...) {
  df <- data.frame(
    Metric = rep(c("CSE", "CAE", "CAPE", "SCAPE"), each = 4),
    Level  = rep(paste0("L", 1:4), 4),
    Value  = c(x$metrics$CSE, x$metrics$CAE,
               x$metrics$CAPE, x$metrics$SCAPE)
  )
  df$Level <- factor(df$Level, levels = c("L4", "L3", "L2", "L1"))

  if (type == "bar") {
    ggplot2::ggplot(df, ggplot2::aes(x = .data$Metric,
                                     y = .data$Value,
                                     fill = .data$Level)) +
      ggplot2::geom_bar(stat = "identity", position = "dodge") +
      ggplot2::labs(title = "Accuracy-Level Metrics",
                    y = "Percentage (%)", x = "Metric") +
      ggplot2::theme_minimal() +
      ggplot2::scale_fill_brewer(palette = "RdYlGn", direction = -1)
  } else if (type == "stacked") {
    ggplot2::ggplot(df, ggplot2::aes(x = .data$Metric,
                                     y = .data$Value,
                                     fill = .data$Level)) +
      ggplot2::geom_bar(stat = "identity") +
      ggplot2::labs(title = "Accuracy-Level Metrics (Stacked)",
                    y = "Percentage (%)", x = "Metric") +
      ggplot2::theme_minimal() +
      ggplot2::scale_fill_brewer(palette = "RdYlGn", direction = -1)
  } else {
    l1 <- x$metrics[1, -1]
    ggplot2::ggplot(
      data.frame(Metric = names(l1), L1 = as.numeric(l1)),
      ggplot2::aes(x = .data$Metric, y = .data$L1)
    ) +
      ggplot2::geom_bar(stat = "identity", fill = "#2ca02c") +
      ggplot2::labs(title = "Level 1 Accuracy Comparison",
                    y = "L1 Percentage (%)", x = "Metric") +
      ggplot2::theme_minimal() +
      ggplot2::geom_hline(yintercept = 50, linetype = "dashed", color = "gray")
  }
}

#' @noRd
.plot_accuracy_base <- function(x, type, ...) {
  mat <- as.matrix(x$metrics[, -1])
  if (type == "bar") {
    graphics::barplot(mat, beside = TRUE,
            col  = c("#2ca02c", "#98df8a", "#ffbb78", "#d62728"),
            legend.text = paste0("L", 1:4),
            main = "Accuracy-Level Metrics",
            ylab = "Percentage (%)", xlab = "Metric")
  } else {
    graphics::barplot(mat,
            col  = c("#2ca02c", "#98df8a", "#ffbb78", "#d62728"),
            legend.text = paste0("L", 1:4),
            main = "Accuracy-Level Metrics (Stacked)",
            ylab = "Percentage (%)", xlab = "Metric")
  }
}
