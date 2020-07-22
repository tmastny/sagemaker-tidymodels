#!/usr/bin/env Rscript

library(readr)
library(recipes)
library(parsnip)
library(workflows)
library(rsample)
library(dplyr)
library(janitor)

input_path <- Sys.getenv('SM_CHANNEL_TRAIN')
df <- read_csv(input_path)

split <- initial_split(df)
train <- training(split)
test <- testing(split)


kbin <- c('age', 'num persons worked for employer') %>% janitor::make_clean_names()
ss <- c('capital gains', 'capital losses', 'dividends from stocks') %>% janitor::make_clean_names()
ohe <- c('education', 'major industry code', 'class of worker') %>% janitor::make_clean_names()


preprocess <- recipe(income ~ ., data = train) %>%
  step_rm(-one_of(c(kbin, ss, ohe)), -all_outcomes()) %>%
  step_scale(one_of(ss)) %>%
  step_center(one_of(ss)) %>%
  step_dummy(one_of(ohe), one_hot = TRUE) %>%
  step_discretize(one_of(kbin), num_breaks = 10) %>%
  step_string2factor(all_outcomes())

lm_model <- logistic_reg() %>%
  set_engine('glm')

pipeline <- workflow() %>%
  add_model(lm_model) %>%
  add_recipe(preprocess)

model <- pipeline %>%
  fit(data = train)


model_path <- Sys.getenv('SM_MODEL_DIR')
saveRDS(model, model_path)
