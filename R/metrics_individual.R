# Individual Accuracy-Level Metrics

#' Counted Squared Error (CSE)
#'
#' @description Compute the Counted Squared Error metric at a specified level.
#'
#' @param actual Numeric vector of actual (observed) values.
#' @param predicted Numeric vector of predicted values.
#' @param level Integer (1--4). Level to return. Default is 1.
#' @param threshold An \code{al_threshold} object or \code{NULL} for
#'   automatic calculation.
#' @param baseline_actual Actual values for baseline model threshold
#'   calculation (used only if \code{threshold} is \code{NULL}).
#' @param baseline_predicted Predicted values for baseline model threshold
#'   calculation (used only if \code{threshold} is \code{NULL}).
#' @param as_decimal Logical. If \code{TRUE}, return as proportion (0--1);
#'   if \code{FALSE} (default), return as percentage (0--100).
#'
#' @return Numeric scalar: the percentage (or proportion) of observations
#'   at the specified accuracy level.
#'
#' @examples
#' actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
#' predicted <- c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56)
#'
#' cse(actual, predicted, level = 1)
#' sapply(1:4, function(l) cse(actual, predicted, level = l))
#'
#' @export
cse <- function(actual, predicted, level = 1, threshold = NULL,
                baseline_actual = NULL, baseline_predicted = NULL,
                as_decimal = FALSE) {
  .validate_level(level)
  al <- accuracy_level(actual, predicted, threshold,
                       baseline_actual, baseline_predicted)
  val <- al$metrics$CSE[level]
  if (as_decimal) val / 100 else val
}

#' Counted Absolute Error (CAE)
#'
#' @inheritParams cse
#' @return Numeric scalar.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' cae(actual, predicted, level = 1)
#'
#' @export
cae <- function(actual, predicted, level = 1, threshold = NULL,
                baseline_actual = NULL, baseline_predicted = NULL,
                as_decimal = FALSE) {
  .validate_level(level)
  al <- accuracy_level(actual, predicted, threshold,
                       baseline_actual, baseline_predicted)
  val <- al$metrics$CAE[level]
  if (as_decimal) val / 100 else val
}

#' Counted Absolute Percentage Error (CAPE)
#'
#' @inheritParams cse
#' @return Numeric scalar.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' cape(actual, predicted, level = 1)
#'
#' @export
cape <- function(actual, predicted, level = 1, threshold = NULL,
                 baseline_actual = NULL, baseline_predicted = NULL,
                 as_decimal = FALSE) {
  .validate_level(level)
  al <- accuracy_level(actual, predicted, threshold,
                       baseline_actual, baseline_predicted)
  val <- al$metrics$CAPE[level]
  if (as_decimal) val / 100 else val
}

#' Symmetric Counted Absolute Percentage Error (SCAPE)
#'
#' @inheritParams cse
#' @return Numeric scalar.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' scape(actual, predicted, level = 1)
#'
#' @export
scape <- function(actual, predicted, level = 1, threshold = NULL,
                  baseline_actual = NULL, baseline_predicted = NULL,
                  as_decimal = FALSE) {
  .validate_level(level)
  al <- accuracy_level(actual, predicted, threshold,
                       baseline_actual, baseline_predicted)
  val <- al$metrics$SCAPE[level]
  if (as_decimal) val / 100 else val
}

#' Get All Levels for a Metric
#'
#' @description Convenience function to obtain all four levels at once.
#'
#' @param actual Numeric vector of actual values.
#' @param predicted Numeric vector of predicted values.
#' @param metric One of \code{"cse"}, \code{"cae"}, \code{"cape"},
#'   \code{"scape"}.
#' @param threshold An \code{al_threshold} object or \code{NULL}.
#' @param baseline_actual Actual values for baseline model.
#' @param baseline_predicted Predicted values for baseline model.
#'
#' @return Named numeric vector of length 4.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' get_all_levels(actual, predicted, "cae")
#'
#' @export
get_all_levels <- function(actual, predicted,
                           metric = c("cse", "cae", "cape", "scape"),
                           threshold = NULL,
                           baseline_actual = NULL,
                           baseline_predicted = NULL) {
  metric <- match.arg(metric)
  al <- accuracy_level(actual, predicted, threshold,
                       baseline_actual, baseline_predicted)
  vals <- al$metrics[[toupper(metric)]]
  stats::setNames(vals, paste0("L", 1:4))
}


#' Compare Multiple Models
#'
#' @description Compare multiple prediction models using accuracy-level
#'   metrics and identify the optimal one following the model-selection
#'   procedure in Figure 3 of Agustini et al. (2026).
#'
#' @details
#' The optimal model is selected by the Figure 3 algorithm:
#' \enumerate{
#'   \item Compare the Level 1 accuracy across models; the model with the
#'     highest value is selected.
#'   \item If two or more models tie on Level 1 accuracy, the tie is broken
#'     using the mean error (ME) of the corresponding level (lower ME is
#'     better).
#'   \item If the ME values are also equal, the comparison proceeds to the
#'     next accuracy level, repeating until the optimal model is identified.
#' }
#' Earlier releases used the simpler rule of ranking by Level 1 then Level 2
#' accuracy; this version implements the full ME-based tie-break.
#'
#' @param ... Named arguments, each a list with \code{actual} and
#'   \code{predicted} elements.
#' @param metric Metric for comparison. Default is \code{"cse"}.
#' @param threshold Shared \code{al_threshold} object. When \code{NULL}
#'   (default), the \emph{first} model is used as the baseline.
#'
#' @return A list with \code{optimal_model}, \code{comparison} table
#'   (accuracy and mean error per level), \code{metric_used}, and
#'   \code{full_results}.
#'
#' @examples
#' actual <- c(7, 6.03, 2.02, 5.1, 9, 1, 3, 4.38, 1, 8.07)
#' m1 <- list(actual = actual,
#'            predicted = c(6.05, 5.02, 1.32, 5.15, 8, 2.2, 2.7, 3.48, 1, 7.56))
#' m3 <- list(actual = actual,
#'            predicted = c(7.01, 6.04, 2.09, 5.11, 9.01, 5.1, 3.01, 4.39, 1, 8.1))
#'
#' res <- compare_models(Model1 = m1, Model3 = m3, metric = "cape")
#' print(res$comparison)
#' res$optimal_model
#'
#' @export
compare_models <- function(...,
                           metric = c("cse", "cae", "cape", "scape"),
                           threshold = NULL) {
  metric <- match.arg(metric)
  models <- list(...)

  if (length(models) < 2L) {
    stop("At least two models must be provided.", call. = FALSE)
  }

  # Use first model as baseline when no threshold supplied
  if (is.null(threshold)) {
    first <- models[[1]]
    if (!all(c("actual", "predicted") %in% names(first))) {
      stop("Each model must have 'actual' and 'predicted' elements.", call. = FALSE)
    }
    threshold <- auto_threshold(first$actual, first$predicted)
  }

  results <- lapply(names(models), function(nm) {
    m <- models[[nm]]
    if (!all(c("actual", "predicted") %in% names(m))) {
      stop("Each model must have 'actual' and 'predicted' elements.", call. = FALSE)
    }
    al <- accuracy_level(m$actual, m$predicted, threshold = threshold)
    me_col <- paste0("ME_", toupper(metric))
    list(name = nm,
         levels = al$metrics[[toupper(metric)]],
         me     = al$mean_errors[[me_col]],
         full   = al)
  })

  comparison <- do.call(rbind, lapply(results, function(r) {
    data.frame(Model = r$name,
               L1 = r$levels[1], L2 = r$levels[2],
               L3 = r$levels[3], L4 = r$levels[4],
               ME_L1 = r$me[1], ME_L2 = r$me[2],
               ME_L3 = r$me[3], ME_L4 = r$me[4],
               stringsAsFactors = FALSE)
  }))
  row.names(comparison) <- NULL

  # Optimal model via Figure 3: compare accuracy per level; on ties use the
  # mean error of that level (lower is better); if still tied, move to the
  # next level.
  acc_mat <- as.matrix(comparison[, c("L1", "L2", "L3", "L4")])
  me_mat  <- as.matrix(comparison[, c("ME_L1", "ME_L2", "ME_L3", "ME_L4")])
  idx <- .select_optimal(acc_mat, me_mat)

  list(
    optimal_model = comparison$Model[idx],
    comparison    = comparison,
    metric_used   = metric,
    full_results  = stats::setNames(
      lapply(results, function(r) r$full), sapply(results, function(r) r$name)
    )
  )
}


# ---- internal ----
#' @noRd
.validate_level <- function(level) {
  if (!level %in% 1:4) {
    stop("'level' must be 1, 2, 3, or 4.", call. = FALSE)
  }
}

#' Select the optimal model following Figure 3 of Agustini et al. (2026)
#'
#' For each accuracy level (1 to 4) the candidate set is restricted to the
#' models achieving the highest accuracy at that level. When more than one
#' model ties, the tie is broken by the lower mean error (ME) at the same
#' level. If accuracy and ME are both tied the procedure advances to the
#' next level. If candidates remain tied after all levels, the first is
#' returned.
#'
#' @param acc_mat Numeric matrix (models x 4) of accuracy percentages.
#' @param me_mat Numeric matrix (models x 4) of mean errors (NA allowed).
#' @param tol Numeric tolerance for treating values as equal.
#'
#' @return Integer index of the selected (optimal) model row.
#' @noRd
.select_optimal <- function(acc_mat, me_mat, tol = 1e-8) {
  candidates <- seq_len(nrow(acc_mat))

  for (k in 1:4) {
    if (length(candidates) == 1L) break

    # 1) keep models with the highest accuracy at level k
    acc_k <- acc_mat[candidates, k]
    best_acc <- max(acc_k)
    keep <- candidates[abs(acc_k - best_acc) <= tol]
    if (length(keep) == 1L) { candidates <- keep; break }

    # 2) among ties, prefer the lowest mean error at level k
    me_k <- me_mat[keep, k]
    if (all(is.na(me_k))) {
      candidates <- keep            # no ME information: carry ties forward
    } else {
      best_me <- min(me_k, na.rm = TRUE)
      keep2 <- keep[!is.na(me_k) & abs(me_k - best_me) <= tol]
      if (length(keep2) == 1L) { candidates <- keep2; break }
      candidates <- if (length(keep2) >= 1L) keep2 else keep
    }
  }
  candidates[1]
}
