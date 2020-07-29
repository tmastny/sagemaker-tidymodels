model_fn <- readRDS

input_fn <- function(request_body, model) {
  input <- read.csv(text = request_body, header = FALSE, strip.white = TRUE)

  col_names <- names(model$pre$mold$predictors)
  if (!is.null(model$pre$actions$recipe)) {
    col_names <- model$pre$actions$recipe$recipe$var_info$variable
  }

  # without recipe, this is how to get predictors:
  #   names(model$pre$mold$predictors)
  # it doesn't work when there is a recipe: these are the trained
  # predictors, whose name may have changed
  # this functionally should eventually live in `leadr`

  names(input) <- col_names
  input
}

predict_fn <- function(model, new_data) {
  predict(model, new_data)
}

output_fn <- function(pred) {
  readr::format_csv(pred, col_names = FALSE)
}
