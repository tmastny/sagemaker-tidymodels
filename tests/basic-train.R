#!/usr/bin/env Rscript

library(tidymodels)

if (sys.nframe() == 0) {

  input_path <- file.path(Sys.getenv('SM_CHANNEL_TRAIN'), "census-income.csv")
  df <- read.csv('data/census-income.csv', stringsAsFactors = TRUE)


  pipeline <- workflow() %>%
    add_formula(income ~ age) %>%
    add_model(logistic_reg() %>% set_engine("glm"))

  model <- pipeline %>%
    fit(data = df)

  output_path <- file.path(Sys.getenv('SM_MODEL_DIR'), "model.RDS")
  saveRDS(model, output_path)
}
