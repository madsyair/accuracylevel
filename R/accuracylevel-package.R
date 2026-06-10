#' accuracylevel: Robust Accuracy-Level Metrics for Predictive Model Evaluation
#'
#' @description
#' The \pkg{accuracylevel} package implements novel accuracy-level metrics for
#' evaluating continuous data prediction models. These metrics offer robust,
#' consistent, and interpretable evaluation on a 0--100\% scale, addressing
#' limitations of conventional metrics like RMSE, MAE, and MAPE.
#'
#' @section Main Functions:
#' \describe{
#'   \item{\code{\link{accuracy_level}}}{Compute all accuracy-level metrics
#'     (CSE, CAE, CAPE, SCAPE).}
#'   \item{\code{\link{cse}}, \code{\link{cae}}, \code{\link{cape}},
#'     \code{\link{scape}}}{Individual metric convenience functions.}
#' }
#'
#' @section Threshold Functions:
#' \describe{
#'   \item{\code{\link{calculate_threshold}}}{Calculate error thresholds from
#'     a baseline model.}
#'   \item{\code{\link{auto_threshold}}}{Automatic quartile selection based on
#'     a target APE.}
#' }
#'
#' @section Integration:
#' \describe{
#'   \item{\code{\link{caret_summary}}}{caret package integration.}
#'   \item{\code{\link{cse_l1}}, \code{\link{cae_l1}}, etc.}{tidymodels /
#'     yardstick integration.}
#'   \item{\code{\link{al_forecast_accuracy}}}{forecast package integration.}
#' }
#'
#' @section Comparison:
#' \describe{
#'   \item{\code{\link{conventional_metrics}}}{RMSE, MAE, MAPE, etc.}
#'   \item{\code{\link{robust_metrics}}}{MedAE, Huber, trimmed MSE, etc.}
#'   \item{\code{\link{compare_all_metrics}}}{Side-by-side comparison.}
#' }
#'
#' @references
#' Agustini, M., Fithriasari, K., & Prastyo, D.D. (2026). An accuracy-level
#' method for robust evaluation in predictive analytics. \emph{Decision
#' Analytics Journal}, 18, 100661. \doi{10.1016/j.dajour.2025.100661}
#'
#' @docType package
#' @name accuracylevel-package
#' @aliases accuracylevel
#' @keywords internal
"_PACKAGE"

#' @importFrom stats complete.cases cor median quantile sd setNames
#' @importFrom graphics barplot
NULL

# Suppress R CMD check NOTEs for ggplot2 .data pronoun
utils::globalVariables(c(".data"))
