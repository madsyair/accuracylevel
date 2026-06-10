# Integration with tidymodels / yardstick

# ---- Individual L1 metrics (S3 generics + data.frame methods) ----

#' CSE Level 1 Metric for yardstick
#'
#' @param data A data frame containing truth and estimate columns.
#' @param truth Column name for actual values (unquoted).
#' @param estimate Column name for predicted values (unquoted).
#' @param na_rm Logical. Remove \code{NA}s? Default \code{TRUE}.
#' @param ... Additional arguments (ignored).
#'
#' @return A tibble with \code{.metric}, \code{.estimator}, \code{.estimate}.
#'
#' @examples
#' \donttest{
#' if (requireNamespace("rlang", quietly = TRUE)) {
#'   df <- data.frame(truth = c(10, 20, 30), estimate = c(11, 19, 28))
#'   cse_l1(df, truth, estimate)
#' }
#' }
#'
#' @export
cse_l1 <- function(data, truth, estimate, na_rm = TRUE, ...) {
  UseMethod("cse_l1")
}

#' @rdname cse_l1
#' @export
cse_l1.data.frame <- function(data, truth, estimate, na_rm = TRUE, ...) {
  vecs <- .tidy_extract(data, rlang::enquo(truth), rlang::enquo(estimate), na_rm)
  .create_metric_tibble("cse_l1", cse(vecs$actual, vecs$predicted, level = 1))
}

#' CAE Level 1 Metric for yardstick
#' @inheritParams cse_l1
#' @return A tibble.
#' @export
cae_l1 <- function(data, truth, estimate, na_rm = TRUE, ...) {
 UseMethod("cae_l1")
}
#' @rdname cae_l1
#' @export
cae_l1.data.frame <- function(data, truth, estimate, na_rm = TRUE, ...) {
  vecs <- .tidy_extract(data, rlang::enquo(truth), rlang::enquo(estimate), na_rm)
  .create_metric_tibble("cae_l1", cae(vecs$actual, vecs$predicted, level = 1))
}

#' CAPE Level 1 Metric for yardstick
#' @inheritParams cse_l1
#' @return A tibble.
#' @export
cape_l1 <- function(data, truth, estimate, na_rm = TRUE, ...) {
  UseMethod("cape_l1")
}
#' @rdname cape_l1
#' @export
cape_l1.data.frame <- function(data, truth, estimate, na_rm = TRUE, ...) {
  vecs <- .tidy_extract(data, rlang::enquo(truth), rlang::enquo(estimate), na_rm)
  .create_metric_tibble("cape_l1", cape(vecs$actual, vecs$predicted, level = 1))
}

#' SCAPE Level 1 Metric for yardstick
#' @inheritParams cse_l1
#' @return A tibble.
#' @export
scape_l1 <- function(data, truth, estimate, na_rm = TRUE, ...) {
  UseMethod("scape_l1")
}
#' @rdname scape_l1
#' @export
scape_l1.data.frame <- function(data, truth, estimate, na_rm = TRUE, ...) {
  vecs <- .tidy_extract(data, rlang::enquo(truth), rlang::enquo(estimate), na_rm)
  .create_metric_tibble("scape_l1", scape(vecs$actual, vecs$predicted, level = 1))
}

# ---- Full accuracy-level metrics ----

#' Full Accuracy-Level Metrics for yardstick
#'
#' @inheritParams cse_l1
#' @return A tibble with 16 rows (4 metrics x 4 levels).
#'
#' @examples
#' \donttest{
#' if (requireNamespace("rlang", quietly = TRUE)) {
#'   df <- data.frame(truth = c(10, 20, 30, 40, 50),
#'                    estimate = c(11, 19, 32, 38, 51))
#'   accuracy_level_metrics(df, truth, estimate)
#' }
#' }
#'
#' @export
accuracy_level_metrics <- function(data, truth, estimate, na_rm = TRUE, ...) {
  UseMethod("accuracy_level_metrics")
}

#' @rdname accuracy_level_metrics
#' @export
accuracy_level_metrics.data.frame <- function(data, truth, estimate,
                                               na_rm = TRUE, ...) {
  vecs <- .tidy_extract(data, rlang::enquo(truth), rlang::enquo(estimate), na_rm)
  result <- accuracy_level(vecs$actual, vecs$predicted)

  df <- data.frame(
    .metric    = c(paste0("cse_l",   1:4), paste0("cae_l",   1:4),
                   paste0("cape_l",  1:4), paste0("scape_l", 1:4)),
    .estimator = "standard",
    .estimate  = c(result$metrics$CSE, result$metrics$CAE,
                   result$metrics$CAPE, result$metrics$SCAPE),
    stringsAsFactors = FALSE
  )
  if (requireNamespace("tibble", quietly = TRUE)) tibble::as_tibble(df) else df
}

#' Create Metric Set for tidymodels
#'
#' @param include_traditional Logical. If \code{TRUE} (default), also include
#'   rmse, mae, and rsq from \pkg{yardstick}.
#'
#' @return A metric set function.
#'
#' @note The level-1 metrics in the set derive their error thresholds from the
#'   data being evaluated (a self-referential baseline). In resampling or
#'   cross-validation, each fold therefore uses its own threshold, which limits
#'   strict cross-fold comparability. For a fixed baseline across folds,
#'   evaluate with \code{\link{accuracy_level}} using a pre-computed
#'   \code{al_threshold} object (see \code{\link{calculate_threshold}}).
#'   Case weights are not supported; any \code{case_weights} passed by
#'   \pkg{tune} are ignored.
#'
#' @examples
#' \donttest{
#' if (requireNamespace("yardstick", quietly = TRUE)) {
#'   al_metrics <- al_metric_set()
#' }
#' }
#'
#' @export
al_metric_set <- function(include_traditional = TRUE) {
  if (!requireNamespace("yardstick", quietly = TRUE)) {
    stop("Package 'yardstick' is required.", call. = FALSE)
  }

  # Wrap our generics as yardstick numeric metrics with a direction.
  # Prefer the official constructor; fall back to manual class assignment
  # for older yardstick versions that lack new_numeric_metric().
  wrap_numeric <- function(fn, dir = "maximize") {
    if (exists("new_numeric_metric", where = asNamespace("yardstick"),
               inherits = FALSE)) {
      yardstick::new_numeric_metric(fn, direction = dir)
    } else {
      out <- fn
      class(out) <- c("numeric_metric", "metric", "function")
      attr(out, "direction") <- dir
      out
    }
  }

  al_cse   <- wrap_numeric(cse_l1,   "maximize")
  al_cae   <- wrap_numeric(cae_l1,   "maximize")
  al_cape  <- wrap_numeric(cape_l1,  "maximize")
  al_scape <- wrap_numeric(scape_l1, "maximize")

  if (include_traditional) {
    yardstick::metric_set(al_cse, al_cae, al_cape, al_scape,
                          yardstick::rmse, yardstick::mae, yardstick::rsq)
  } else {
    yardstick::metric_set(al_cse, al_cae, al_cape, al_scape)
  }
}

# ---- internal helpers ----

#' Extract truth / estimate from a data frame using tidy evaluation
#' @noRd
.tidy_extract <- function(data, truth_quo, estimate_quo, na_rm) {
  if (!requireNamespace("rlang", quietly = TRUE)) {
    stop("Package 'rlang' is required for tidymodels integration.", call. = FALSE)
  }
  a <- rlang::eval_tidy(truth_quo,    data)
  p <- rlang::eval_tidy(estimate_quo, data)
  if (na_rm) {
    ok <- stats::complete.cases(a, p)
    a <- a[ok]; p <- p[ok]
  }
  list(actual = a, predicted = p)
}

#' Create a one-row metric tibble
#' @noRd
.create_metric_tibble <- function(name, value) {
  df <- data.frame(.metric = name, .estimator = "standard",
                   .estimate = value, stringsAsFactors = FALSE)
  if (requireNamespace("tibble", quietly = TRUE)) tibble::as_tibble(df) else df
}
