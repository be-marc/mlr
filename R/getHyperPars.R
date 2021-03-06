#' @title Get current parameter settings for a learner.
#'
#' @description
#' Retrieves the current hyperparameter settings of a learner.
#'
#' @param learner ([Learner])\cr
#'   The learner.
#' @param for.fun (`character(1)`)\cr
#'   Restrict the returned settings to hyperparameters corresponding to `when`
#'   the are used (see [ParamHelpers::LearnerParam]).
#'   Must be a subset of: \dQuote{train}, \dQuote{predict} or \dQuote{both}.
#'   Default is `c("train", "predict", "both")`.
#' @return ([list]). A named list of values.
#' @family learner
#' @export
getHyperPars = function(learner, for.fun = c("train", "predict", "both")) {
  assertSubset(for.fun, choices = c("train", "predict", "both"))
  UseMethod("getHyperPars")
}

#' @export
getHyperPars.Learner = function(learner, for.fun = c("train", "predict", "both")) {
  assertClass(learner, classes = "Learner")
  pars = learner$par.set$pars
  pv = learner$par.vals
  ns = Filter(function(x) pars[[x]]$when %in% for.fun, names(pv))
  pv[ns]
}

getHyperParsString = function(learner, show.missing.values = TRUE) {
  hps = getHyperPars(learner)
  ns = names(hps)
  pars = getParamSet(learner)$pars[ns]
  s = mapply(paramValueToString, pars, hps, MoreArgs = list(show.missing.values = show.missing.values))
  stri_paste(ns, s, sep = "=", collapse = ",")
}
