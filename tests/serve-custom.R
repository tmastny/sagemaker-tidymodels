model_fn <- function(path) {
  print("__custom-model_fn__")
  readRDS(path)
}

input_fn <- function(request_body, model) {
  print("__custom-input_fn__")

  input <- read.csv(text = request_body, header = FALSE, strip.white = TRUE)

  col_names <- model$pre$actions$recipe$recipe$var_info$variable

  names(input) <- col_names
  input
}


predict_fn <- function(model, new_data) {
  print("__custom-predict_fn__")

  predict(model, new_data)
}


output_fn <- function(pred) {
  print("__custom-output_fn__")

  readr::format_csv(pred, col_names = FALSE)
}
