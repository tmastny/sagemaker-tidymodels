model_fn <- readRDS

input_fn <- function(request_body, model) {
  input <- read.csv(text = request_body, header = FALSE, strip.white = TRUE)

  col_names <- model$pre$actions$recipe$recipe$var_info$variable

  names(input) <- col_names
  input
}

predict_fn <- function(model, new_data) {
  predict(model, new_data)
}

output_fn <- function(pred) {
  readr::format_csv(pred, col_names = FALSE)
}
