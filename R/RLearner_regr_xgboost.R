#' @export
makeRLearner.regr.xgboost = function() {
  makeRLearnerRegr(
    cl = "regr.xgboost",
    package = "xgboost",
    par.set = makeParamSet(
      # we pass all of what goes in 'params' directly to ... of xgboost
      # makeUntypedLearnerParam(id = "params", default = list()),
      makeDiscreteLearnerParam(id = "booster", default = "gbtree", values = c("gbtree", "gblinear", "dart")),
      makeUntypedLearnerParam(id = "watchlist", default = NULL, tunable = FALSE),
      makeNumericLearnerParam(id = "eta", default = 0.3, lower = 0, upper = 1),
      makeNumericLearnerParam(id = "gamma", default = 0, lower = 0),
      makeIntegerLearnerParam(id = "max_depth", default = 6L, lower = 1L),
      makeNumericLearnerParam(id = "min_child_weight", default = 1, lower = 0),
      makeNumericLearnerParam(id = "subsample", default = 1, lower = 0, upper = 1),
      makeNumericLearnerParam(id = "colsample_bytree", default = 1, lower = 0, upper = 1),
      makeNumericLearnerParam(id = "colsample_bylevel", default = 1, lower = 0, upper = 1),
      makeIntegerLearnerParam(id = "num_parallel_tree", default = 1L, lower = 1L),
      makeNumericLearnerParam(id = "lambda", default = 1, lower = 0),
      makeNumericLearnerParam(id = "lambda_bias", default = 0, lower = 0),
      makeNumericLearnerParam(id = "alpha", default = 0, lower = 0),
      makeUntypedLearnerParam(id = "objective", default = "reg:linear", tunable = FALSE),
      makeUntypedLearnerParam(id = "eval_metric", default = "rmse", tunable = FALSE),
      makeNumericLearnerParam(id = "base_score", default = 0.5, tunable = FALSE),
      makeNumericLearnerParam(id = "max_delta_step", lower = 0, default = 0),
      makeNumericLearnerParam(id = "missing", default = NA, tunable = FALSE, when = "both",
        special.vals = list(NA, NA_real_, NULL)),
      makeIntegerVectorLearnerParam(id = "monotone_constraints", default = 0, lower = -1, upper = 1),
      makeNumericLearnerParam(id = "tweedie_variance_power", lower = 1, upper = 2, default = 1.5, requires = quote(objective == "reg:tweedie")),
      makeIntegerLearnerParam(id = "nthread", lower = 1L, tunable = FALSE),
      makeIntegerLearnerParam(id = "nrounds", default = 1L, lower = 1L),
      # FIXME nrounds seems to have no default in xgboost(), if it has 1, par.vals is redundant
      makeUntypedLearnerParam(id = "feval", default = NULL, tunable = FALSE),
      makeIntegerLearnerParam(id = "verbose", default = 1L, lower = 0L, upper = 2L, tunable = FALSE),
      makeIntegerLearnerParam(id = "print_every_n", default = 1L, lower = 1L, tunable = FALSE,
        requires = quote(verbose == 1L)),
      makeIntegerLearnerParam(id = "early_stopping_rounds", default = NULL, lower = 1L, special.vals = list(NULL), tunable = FALSE),
      makeLogicalLearnerParam(id = "maximize", default = NULL, special.vals = list(NULL), tunable = FALSE),
      makeDiscreteLearnerParam(id = "sample_type", default = "uniform", values = c("uniform", "weighted"), requires = quote(booster == "dart")),
      makeDiscreteLearnerParam(id = "normalize_type", default = "tree", values = c("tree", "forest"), requires = quote(booster == "dart")),
      makeNumericLearnerParam(id = "rate_drop", default = 0, lower = 0, upper = 1, requires = quote(booster == "dart")),
      makeNumericLearnerParam(id = "skip_drop", default = 0, lower = 0, upper = 1, requires = quote(booster == "dart")),
      # TODO: uncomment the following after the next CRAN update, and set max_depth's lower = 0L
      # makeLogicalLearnerParam(id = "one_drop", default = FALSE, requires = quote(booster == "dart")),
      # makeDiscreteLearnerParam(id = "tree_method", default = "exact", values = c("exact", "hist"), requires = quote(booster != "gblinear")),
      # makeDiscreteLearnerParam(id = "grow_policy", default = "depthwise", values = c("depthwise", "lossguide"), requires = quote(tree_method == "hist")),
      # makeIntegerLearnerParam(id = "max_leaves", default = 0L, lower = 0L, requires = quote(grow_policy == "lossguide")),
      # makeIntegerLearnerParam(id = "max_bin", default = 256L, lower = 2L, requires = quote(tree_method == "hist")),
      makeUntypedLearnerParam(id = "callbacks", default = list(), tunable = FALSE)
    ),
    par.vals = list(nrounds = 1L, verbose = 0L),
    properties = c("numerics", "weights", "featimp", "missings"),
    name = "eXtreme Gradient Boosting",
    short.name = "xgboost",
    note = "All settings are passed directly, rather than through `xgboost`'s `params` argument. `nrounds` has been set to `1` and `verbose` to `0` by default.",
    callees = "xgboost"
  )
}

#' @export
trainLearner.regr.xgboost = function(.learner, .task, .subset, .weights = NULL, ...) {

  parlist = list(...)

  if (is.null(parlist$objective)) {
    parlist$objective = "reg:linear"
  }

  task.data = getTaskData(.task, .subset, target.extra = TRUE)
  parlist$data = xgboost::xgb.DMatrix(data = data.matrix(task.data$data), label = task.data$target)

  if (!is.null(.weights)) {
    xgboost::setinfo(parlist$data, "weight", .weights)
  }

  if (is.null(parlist$watchlist)) {
    parlist$watchlist = list(train = parlist$data)
  }

  do.call(xgboost::xgb.train, parlist)
}

#' @export
predictLearner.regr.xgboost = function(.learner, .model, .newdata, ...) {
  m = .model$learner.model
  predict(m, newdata = data.matrix(.newdata), ...)
}

#' @export
getFeatureImportanceLearner.regr.xgboost = function(.learner, .model, ...) {
  getFeatureImportanceLearner.classif.xgboost(.learner, .model, ...)
}
