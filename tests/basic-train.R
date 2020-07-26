#!/usr/bin/env Rscript

library(tidymodels)
library(readr)

if (sys.nframe() == 0) {

  input_path <- file.path(Sys.getenv('SM_CHANNEL_TRAIN'), "census-income.csv")
  df <- read_csv(input_path, trim_ws = TRUE)

  pipeline <- workflow() %>%
    add_formula(`wage per hour` ~ age) %>%
    add_model(linear_reg() %>% set_engine("lm"))

  model <- pipeline %>%
    fit(data = df)

  output_path <- file.path(Sys.getenv('SM_MODEL_DIR'), "model.RDS")
  saveRDS(model, output_path)
}
