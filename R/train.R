#!/usr/bin/env Rscript

library(readr)
library(recipes)
library(parsnip)
library(workflows)
library(rsample)
library(dplyr)
library(janitor)

test_fn2 <- function() {
  print("hello from other func!!!")
}


if (sys.nframe() == 0) {

  input_path <- file.path(Sys.getenv('SM_CHANNEL_TRAIN'), "census-income.csv")
  print(input_path)
  df <- read_csv(input_path, trim_ws = TRUE) %>%
    clean_names()

  print('split')
  split <- initial_split(df)
  train <- training(split)
  test <- testing(split)


  kbin <- c('age', 'num persons worked for employer') %>% make_clean_names()
  ss <- c('capital gains', 'capital losses', 'dividends from stocks') %>% make_clean_names()
  ohe <- c('education', 'major industry code', 'class of worker') %>% make_clean_names()
  all_vars <- c(kbin, ss, ohe)

  print('recipe')
  preprocess <- recipe(income ~ ., data = train) %>%
    step_rm(-one_of(all_vars), -all_outcomes()) %>%
    step_scale(one_of(ss)) %>%
    step_center(one_of(ss)) %>%
    step_dummy(one_of(ohe), one_hot = TRUE) %>%
    step_discretize(one_of(kbin), num_breaks = 10) %>%
    step_string2factor(all_outcomes(), skip = TRUE)

  print('model')
  lm_model <- logistic_reg() %>%
    set_engine('glm')

  pipeline <- workflow() %>%
    add_model(lm_model) %>%
    add_recipe(preprocess)

  print('fit')
  model <- pipeline %>%
    fit(data = train)


  model_path <- file.path(Sys.getenv('SM_MODEL_DIR'), "model.RDS")
  print(model_path)
  saveRDS(model, model_path)
}
