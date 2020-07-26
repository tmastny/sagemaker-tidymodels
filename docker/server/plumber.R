library(recipes)
library(parsnip)
library(workflows)

#' Ping to show server is there
#' @get /ping
function() {
  return('')
}


#' Parse input and return the prediction from the model
#' @param req The http request sent
#' @post /invocations
function(req) {
  prefix <- '/opt/ml'
  model_path <- file.path(prefix, 'model')

  model <- model_fn(file.path(model_path, 'model.RDS'))
  data <- input_fn(req$postBody, model)

  pred <- predict_fn(model, data)

  output_fn(pred)
}
