# Integration with caret Package

#' Create Custom caret Metrics
#'
#' @description Create a summary function for use with caret's
#'   \code{trainControl}. Returns L1 accuracy for all four metrics
#'   plus traditional metrics.
#'
#' @param threshold An optional \code{al_threshold} object for consistent
#'   thresholds across folds. If \code{NULL}, thresholds are calculated
#'   per fold.
#'
#' @return A function suitable for \code{summaryFunction} in
#'   \code{caret::trainControl}.
#'
#' @examples
#' \donttest{
#' if (requireNamespace("caret", quietly = TRUE)) {
#'   al_summary <- caret_summary()
#' }
#' }
#'
#' @export
caret_summary <- function(threshold = NULL) {
  function(data, lev = NULL, model = NULL) {
    if (!all(c("obs", "pred") %in% names(data))) {
      stop("data must contain 'obs' and 'pred' columns.", call. = FALSE)
    }
    actual    <- data$obs
    predicted <- data$pred

    result <- tryCatch(
      accuracy_level(actual, predicted, threshold = threshold),
      error = function(e) NULL
    )

    if (is.null(result)) {
      return(c(CSE_L1 = NA_real_, CAE_L1 = NA_real_,
               CAPE_L1 = NA_real_, SCAPE_L1 = NA_real_,
               RMSE = sqrt(mean((actual - predicted)^2)),
               MAE = mean(abs(actual - predicted)),
               Rsquared = stats::cor(actual, predicted)^2))
    }

    c(
      CSE_L1   = result$metrics$CSE[1],
      CAE_L1   = result$metrics$CAE[1],
      CAPE_L1  = result$metrics$CAPE[1],
      SCAPE_L1 = result$metrics$SCAPE[1],
      RMSE     = sqrt(mean((actual - predicted)^2)),
      MAE      = mean(abs(actual - predicted)),
      Rsquared = stats::cor(actual, predicted)^2
    )
  }
}

#' Create Extended caret Summary with All Levels
#'
#' @inheritParams caret_summary
#'
#' @return A function suitable for \code{summaryFunction} in
#'   \code{caret::trainControl}.
#'
#' @examples
#' \donttest{
#' if (requireNamespace("caret", quietly = TRUE)) {
#'   al_ext <- caret_summary_extended()
#' }
#' }
#'
#' @export
caret_summary_extended <- function(threshold = NULL) {
  function(data, lev = NULL, model = NULL) {
    if (!all(c("obs", "pred") %in% names(data))) {
      stop("data must contain 'obs' and 'pred' columns.", call. = FALSE)
    }

    result <- tryCatch(
      accuracy_level(data$obs, data$pred, threshold = threshold),
      error = function(e) NULL
    )

    if (is.null(result)) {
      out <- stats::setNames(rep(NA_real_, 20),
        c(paste0("CSE_L", 1:4), paste0("CAE_L", 1:4),
          paste0("CAPE_L", 1:4), paste0("SCAPE_L", 1:4),
          "CSE_Opt", "CAE_Opt", "CAPE_Opt", "SCAPE_Opt"))
      return(out)
    }

    m <- result$metrics
    c(
      CSE_L1 = m$CSE[1], CSE_L2 = m$CSE[2], CSE_L3 = m$CSE[3], CSE_L4 = m$CSE[4],
      CAE_L1 = m$CAE[1], CAE_L2 = m$CAE[2], CAE_L3 = m$CAE[3], CAE_L4 = m$CAE[4],
      CAPE_L1 = m$CAPE[1], CAPE_L2 = m$CAPE[2], CAPE_L3 = m$CAPE[3], CAPE_L4 = m$CAPE[4],
      SCAPE_L1 = m$SCAPE[1], SCAPE_L2 = m$SCAPE[2], SCAPE_L3 = m$SCAPE[3], SCAPE_L4 = m$SCAPE[4],
      CSE_Opt   = m$CSE[1]   + m$CSE[2],
      CAE_Opt   = m$CAE[1]   + m$CAE[2],
      CAPE_Opt  = m$CAPE[1]  + m$CAPE[2],
      SCAPE_Opt = m$SCAPE[1] + m$SCAPE[2]
    )
  }
}

#' Create Single Metric caret Summary
#'
#' @param metric_type One of \code{"cse"}, \code{"cae"}, \code{"cape"},
#'   \code{"scape"}.
#' @param level Level to optimise (1--4). Default is 1.
#' @param threshold An \code{al_threshold} object or \code{NULL}.
#'
#' @return A function suitable for \code{summaryFunction} in
#'   \code{caret::trainControl}.
#'
#' @examples
#' \donttest{
#' if (requireNamespace("caret", quietly = TRUE)) {
#'   fn <- caret_single_metric("cae", level = 1)
#' }
#' }
#'
#' @export
caret_single_metric <- function(metric_type = c("cse", "cae", "cape", "scape"),
                                level = 1,
                                threshold = NULL) {
  metric_type <- match.arg(metric_type)
  .validate_level(level)

  function(data, lev = NULL, model = NULL) {
    if (!all(c("obs", "pred") %in% names(data))) {
      stop("data must contain 'obs' and 'pred' columns.", call. = FALSE)
    }
    result <- tryCatch(
      accuracy_level(data$obs, data$pred, threshold = threshold),
      error = function(e) NULL
    )
    if (is.null(result)) return(c(AccuracyLevel = NA_real_))
    c(AccuracyLevel = result$metrics[[toupper(metric_type)]][level])
  }
}
