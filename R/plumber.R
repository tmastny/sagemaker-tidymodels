#' Ping to show server is there
#' @get /ping
function() {
  return('')}


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
  conn <- textConnection(gsub('\\\\n', '\n', req$postBody))
  data <- read.csv(conn)
  close(conn)


  pred <- predict(model, data)

  paste0(pred$.pred_class, collapse = ",")
}
