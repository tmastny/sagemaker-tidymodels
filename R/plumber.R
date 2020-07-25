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

  # Setup locations
  prefix <- '/opt/ml'
  model_path <- file.path(prefix, 'model')

  # Bring in model file and factor levels
  model <- readRDS(file.path(model_path, 'model.RDS'))

  # Read in data
  data <- read.csv(text = req$postBody, header = FALSE, strip.white = TRUE)

  col_names <- model$pre$actions$recipe$recipe$var_info$variable
  names(data) <- col_names


  pred <- predict(model, data)

  paste0(pred$.pred_class, collapse = ",")
}
