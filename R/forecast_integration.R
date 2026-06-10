# Integration with Forecasting Packages

#' Accuracy-Level Metrics for Forecast Objects
#'
#' @description Calculate accuracy-level metrics for forecast objects from
#'   the \pkg{forecast} package, or for plain numeric predictions.
#'
#' @param object A forecast object or numeric vector of predictions.
#' @param test Numeric vector or time series of test (actual) values.
#' @param threshold An \code{al_threshold} object or \code{NULL}.
#'
#' @return An \code{accuracy_level} object.
#'
#' @examples
#' \donttest{
#' # With plain numeric vectors
#' pred <- c(11, 19, 32, 38, 51)
#' actual <- c(10, 20, 30, 40, 50)
#' al_forecast_accuracy(pred, actual)
#' }
#'
#' @export
al_forecast_accuracy <- function(object, test, threshold = NULL) {
  UseMethod("al_forecast_accuracy")
}

#' @rdname al_forecast_accuracy
#' @export
al_forecast_accuracy.default <- function(object, test, threshold = NULL) {
  predicted <- as.numeric(object)
  actual    <- as.numeric(test)
  .reconcile_lengths(actual, predicted)
  n <- min(length(predicted), length(actual))
  accuracy_level(actual[seq_len(n)], predicted[seq_len(n)], threshold)
}

#' @rdname al_forecast_accuracy
#' @export
al_forecast_accuracy.forecast <- function(object, test, threshold = NULL) {
  if (!requireNamespace("forecast", quietly = TRUE)) {
    stop("Package 'forecast' is required for forecast objects.", call. = FALSE)
  }
  predicted <- as.numeric(object$mean)
  actual    <- as.numeric(test)
  .reconcile_lengths(actual, predicted)
  n <- min(length(predicted), length(actual))
  accuracy_level(actual[seq_len(n)], predicted[seq_len(n)], threshold)
}

#' Compare Multiple Forecast Models
#'
#' @param ... Named forecast objects or named lists with \code{forecast}
#'   and \code{test} elements.
#' @param test Test data (used when forecast objects are supplied directly).
#' @param metric Metric for determining the optimal model.
#' @param threshold Shared \code{al_threshold} object or \code{NULL}.
#'
#' @return A list with \code{optimal_model}, \code{comparison} table,
#'   and \code{full_results}.
#'
#' @examples
#' \donttest{
#' actual <- c(10, 20, 30, 40, 50)
#' res <- al_compare_forecasts(
#'   A = list(forecast = c(11, 19, 32, 38, 51), test = actual),
#'   B = list(forecast = c(15, 25, 35, 45, 55), test = actual)
#' )
#' res$comparison
#' }
#'
#' @export
al_compare_forecasts <- function(..., test = NULL,
                                 metric = c("cae", "cape", "cse", "scape"),
                                 threshold = NULL) {
  metric <- match.arg(metric)
  models <- list(...)
  if (length(models) < 2L) {
    stop("At least two models must be provided.", call. = FALSE)
  }

  results <- lapply(names(models), function(nm) {
    m <- models[[nm]]
    al <- if (inherits(m, "forecast")) {
      if (is.null(test)) stop("'test' required for forecast objects.", call. = FALSE)
      al_forecast_accuracy(m, test, threshold)
    } else if (is.list(m) && all(c("forecast", "test") %in% names(m))) {
      al_forecast_accuracy(m$forecast, m$test, threshold)
    } else {
      stop("Invalid model format for '", nm, "'.", call. = FALSE)
    }
    list(name = nm, metrics = al$metrics, al = al)
  })

  comparison <- data.frame(Model = character(0), stringsAsFactors = FALSE)
  for (r in results) {
    row <- data.frame(Model = r$name, stringsAsFactors = FALSE)
    for (mc in c("CSE", "CAE", "CAPE", "SCAPE")) {
      for (l in 1:4) {
        row[[paste0(mc, "_L", l)]] <- r$metrics[[mc]][l]
      }
    }
    comparison <- rbind(comparison, row)
  }
  row.names(comparison) <- NULL

  col <- paste0(toupper(metric), "_L1")
  idx <- which.max(comparison[[col]])

  list(
    optimal_model = comparison$Model[idx],
    comparison    = comparison,
    metric_used   = metric,
    full_results  = stats::setNames(
      lapply(results, `[[`, "al"),
      sapply(results, `[[`, "name")
    )
  )
}

#' Extended Forecast Accuracy Summary
#'
#' @param forecast_obj A forecast object or numeric predictions.
#' @param test Actual test values.
#' @param threshold Optional threshold object.
#'
#' @return A data frame combining traditional and accuracy-level metrics.
#'
#' @examples
#' \donttest{
#' pred <- c(11, 19, 32, 38, 51)
#' actual <- c(10, 20, 30, 40, 50)
#' al_extended_accuracy(pred, actual)
#' }
#'
#' @export
al_extended_accuracy <- function(forecast_obj, test, threshold = NULL) {
  predicted <- if (inherits(forecast_obj, "forecast")) {
    as.numeric(forecast_obj$mean)
  } else {
    as.numeric(forecast_obj)
  }
  actual <- as.numeric(test)
  n <- min(length(predicted), length(actual))
  predicted <- predicted[seq_len(n)]
  actual    <- actual[seq_len(n)]

  errors <- actual - predicted
  trad <- data.frame(
    Metric = c("MAE", "RMSE", "MAPE", "SMAPE"),
    Value  = c(mean(abs(errors)),
               sqrt(mean(errors^2)),
               mean(abs(errors / actual)[is.finite(errors / actual)]) * 100,
               mean(2 * abs(errors) / (abs(actual) + abs(predicted))) * 100),
    Type   = "Traditional",
    stringsAsFactors = FALSE
  )

  al <- accuracy_level(actual, predicted, threshold)
  al_df <- data.frame(
    Metric = c(paste0("CSE_L", 1:4), paste0("CAE_L", 1:4),
               paste0("CAPE_L", 1:4), paste0("SCAPE_L", 1:4)),
    Value  = c(al$metrics$CSE, al$metrics$CAE,
               al$metrics$CAPE, al$metrics$SCAPE),
    Type   = "Accuracy-Level",
    stringsAsFactors = FALSE
  )
  rbind(trad, al_df)
}

#' Time Series Cross-Validation with Accuracy-Level Metrics
#'
#' @param y Numeric time series data.
#' @param forecastfunction Function that accepts \code{(x, h, ...)} and
#'   returns predictions (either a forecast object or numeric vector).
#' @param h Forecast horizon.
#' @param initial Initial training window size.
#' @param window Rolling window size (\code{NULL} for expanding window).
#' @param metric Metric to report.
#' @param ... Additional arguments passed to \code{forecastfunction}.
#'
#' @return A data frame of class \code{"al_tsCV"} with per-fold results.
#'
#' @examples
#' \donttest{
#' ma_fc <- function(x, h) rep(mean(x), h)
#' y <- sin(seq(0, 4 * pi, length.out = 50)) * 10 + 50
#' res <- al_tsCV(y, ma_fc, h = 5, initial = 20)
#' print(res)
#' }
#'
#' @export
al_tsCV <- function(y, forecastfunction, h = 1, initial = 10,
                    window = NULL,
                    metric = c("cae", "cape", "cse", "scape"), ...) {
  metric <- match.arg(metric)
  y <- as.numeric(y)
  n <- length(y)
  if (initial >= n - h) {
    stop("'initial' too large for given data length.", call. = FALSE)
  }

  out <- vector("list", n - h - initial + 1L)
  fold <- 1L
  for (i in initial:(n - h)) {
    start <- if (!is.null(window)) max(1L, i - window + 1L) else 1L
    train <- y[start:i]
    test  <- y[(i + 1L):(i + h)]

    fc <- forecastfunction(train, h = h, ...)
    pred <- if (inherits(fc, "forecast")) as.numeric(fc$mean) else as.numeric(fc)

    al <- tryCatch(accuracy_level(test, pred), error = function(e) NULL)
    out[[fold]] <- data.frame(
      Fold = fold, Training_Size = length(train), Horizon = h,
      CSE_L1   = if (!is.null(al)) al$metrics$CSE[1]   else NA_real_,
      CAE_L1   = if (!is.null(al)) al$metrics$CAE[1]   else NA_real_,
      CAPE_L1  = if (!is.null(al)) al$metrics$CAPE[1]  else NA_real_,
      SCAPE_L1 = if (!is.null(al)) al$metrics$SCAPE[1] else NA_real_,
      stringsAsFactors = FALSE
    )
    fold <- fold + 1L
  }

  result <- do.call(rbind, out)
  attr(result, "summary") <- data.frame(
    Metric = c(paste0("Mean_", c("CSE", "CAE", "CAPE", "SCAPE"), "_L1"),
               paste0("SD_",   c("CSE", "CAE", "CAPE", "SCAPE"), "_L1")),
    Value  = c(mean(result$CSE_L1, na.rm = TRUE),
               mean(result$CAE_L1, na.rm = TRUE),
               mean(result$CAPE_L1, na.rm = TRUE),
               mean(result$SCAPE_L1, na.rm = TRUE),
               stats::sd(result$CSE_L1, na.rm = TRUE),
               stats::sd(result$CAE_L1, na.rm = TRUE),
               stats::sd(result$CAPE_L1, na.rm = TRUE),
               stats::sd(result$SCAPE_L1, na.rm = TRUE)),
    stringsAsFactors = FALSE
  )
  class(result) <- c("al_tsCV", "data.frame")
  result
}

#' @export
print.al_tsCV <- function(x, ...) {
  cat("Time Series Cross-Validation Results\n")
  cat("=====================================\n\n")
  cat("Number of folds:", nrow(x), "\n\n")
  s <- attr(x, "summary")
  if (!is.null(s)) { cat("Summary Statistics:\n"); print(s, row.names = FALSE) }
  cat("\nFirst few folds:\n")
  print(utils::head(as.data.frame(x)), row.names = FALSE)
  invisible(x)
}

# ---- internal ----
#' @noRd
.reconcile_lengths <- function(actual, predicted) {
  if (length(actual) != length(predicted)) {
    warning("Lengths differ. Using first ",
            min(length(actual), length(predicted)),
            " observations.", call. = FALSE)
  }
}
