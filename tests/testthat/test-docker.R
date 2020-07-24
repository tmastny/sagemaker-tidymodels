library(readr)
library(sagemaker)
library(janitor)

test_that("docker executes", {
  d <- read_s3(
    's3://sagemaker-sample-data-us-east-2/processing/census/census-income.csv',
    col_names = TRUE,
    trim_ws = TRUE
  ) %>%
    clean_names()

  d

  model_path <- 's3://sagemaker-us-east-2-495577990003/sagemaker-tidymodels-2020-07-24-00-41-27-665/model.tar.gz'

  system(paste0(
    "aws s3 cp ",
    model_path, " ."
  ))

  untar("model.tar.gz")
  model <- readRDS("model.RDS")

  predict(model, d)
})
