library(recipes)
library(parsnip)
library(workflows)

library(readr)

#' Ping to show server is there
#' @get /ping
function() {
  test_fn()
  test_fn2()
  return('')
}


#' Parse input and return the prediction from the model
#' @param req The http request sent
#' @post /invocations
function(req) {

  test_fn2()

  prefix <- '/opt/ml'
  model_path <- file.path(prefix, 'model')

  # TODO:
  #   consider decomposing into functions like `scikit-learn:
  #   * model_fn
  #   * input_fn
  #   * predict_fn
  #   * output_fn
  model <- readRDS(file.path(model_path, 'model.RDS'))
  col_names <- model$pre$actions$recipe$recipe$var_info$variable


  data <- read.csv(text = req$postBody, header = FALSE, strip.white = TRUE)
  names(data) <- col_names


  pred <- predict(model, data)

  format_csv(pred, col_names = FALSE)
}
