#' Calculate Squared Error
#'
#' @description Compute squared error between actual and predicted values,
#'   as defined in Equation (1) of Agustini et al. (2026).
#'
#' @param actual Numeric vector of actual (observed) values.
#' @param predicted Numeric vector of predicted values.
#' @param na.rm Logical. If \code{TRUE}, remove \code{NA} pairs before
#'   computing. Default is \code{FALSE}.
#'
#' @return Numeric vector of squared errors.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' squared_error(actual, predicted)
#'
#' @references
#' Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
#' method for robust evaluation in predictive analytics. \emph{Decision
#' Analytics Journal}, 18, 100661. \doi{10.1016/j.dajour.2025.100661}
#'
#' @export
squared_error <- function(actual, predicted, na.rm = FALSE) {
  vecs <- .prepare_inputs(actual, predicted, na.rm)
  (vecs$actual - vecs$predicted)^2
}

#' Calculate Absolute Error
#'
#' @description Compute absolute error between actual and predicted values,
#'   as defined in Equation (2) of Agustini et al. (2026).
#'
#' @inheritParams squared_error
#'
#' @return Numeric vector of absolute errors.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' absolute_error(actual, predicted)
#'
#' @export
absolute_error <- function(actual, predicted, na.rm = FALSE) {
  vecs <- .prepare_inputs(actual, predicted, na.rm)
  abs(vecs$actual - vecs$predicted)
}

#' Calculate Absolute Percentage Error
#'
#' @description Compute absolute percentage error between actual and predicted
#'   values, as defined in Equation (3) of Agustini et al. (2026). Note that
#'   the result is on the proportion scale (not multiplied by 100).
#'
#' @inheritParams squared_error
#'
#' @return Numeric vector of absolute percentage errors. Returns \code{Inf}
#'   for observations where \code{actual} is zero.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' absolute_percentage_error(actual, predicted)
#'
#' @export
absolute_percentage_error <- function(actual, predicted, na.rm = FALSE) {
  vecs <- .prepare_inputs(actual, predicted, na.rm)
  abs((vecs$actual - vecs$predicted) / vecs$actual)
}

#' Calculate Symmetric Absolute Percentage Error
#'
#' @description Compute symmetric absolute percentage error between actual
#'   and predicted values, as defined in Equation (4) of Agustini et al.
#'   (2026). Note that the result is on the proportion scale (not multiplied
#'   by 100).
#'
#' @inheritParams squared_error
#'
#' @return Numeric vector of symmetric absolute percentage errors. Returns
#'   \code{NaN} when both actual and predicted are zero.
#'
#' @examples
#' actual <- c(10, 20, 30, 40, 50)
#' predicted <- c(11, 19, 32, 38, 51)
#' symmetric_absolute_percentage_error(actual, predicted)
#'
#' @export
symmetric_absolute_percentage_error <- function(actual, predicted, na.rm = FALSE) {
  vecs <- .prepare_inputs(actual, predicted, na.rm)
  abs(vecs$actual - vecs$predicted) /
    ((abs(vecs$actual) + abs(vecs$predicted)) / 2)
}

# ---- Internal helpers ----

#' Validate and Prepare Input Vectors
#'
#' @param actual Actual values vector.
#' @param predicted Predicted values vector.
#' @param na.rm Whether to remove NA pairs.
#'
#' @return A list with cleaned actual and predicted vectors.
#' @noRd
.prepare_inputs <- function(actual, predicted, na.rm = FALSE) {
  if (!is.numeric(actual)) {
    stop("'actual' must be a numeric vector.", call. = FALSE)
  }
  if (!is.numeric(predicted)) {
    stop("'predicted' must be a numeric vector.", call. = FALSE)
  }
  if (length(actual) != length(predicted)) {
    stop("'actual' and 'predicted' must have the same length.", call. = FALSE)
  }
  if (na.rm) {
    complete <- stats::complete.cases(actual, predicted)
    actual <- actual[complete]
    predicted <- predicted[complete]
  } else if (anyNA(actual) || anyNA(predicted)) {
    stop(
      "Missing values found. Use na.rm = TRUE to remove them, ",
      "or handle NAs before calling this function.",
      call. = FALSE
    )
  }
  if (length(actual) == 0L) {
    stop("Input vectors must have at least one element.", call. = FALSE)
  }
  list(actual = actual, predicted = predicted)
}

#' Validate Input Vectors (simple, no NA handling)
#'
#' @param actual Actual values vector.
#' @param predicted Predicted values vector.
#' @return NULL (invisibly). Throws error if validation fails.
#' @noRd
.validate_inputs <- function(actual, predicted) {
  .prepare_inputs(actual, predicted, na.rm = FALSE)
  invisible(NULL)
}
