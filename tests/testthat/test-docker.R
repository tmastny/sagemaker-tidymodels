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


  d[1,] %>%
    write_csv("example-data.csv", col_names = FALSE)


  raw_data <- read_file("example-data.csv")
  ex_data <- read_csv(raw_data, col_names = FALSE, trim_ws = TRUE)

  col_names <- model$pre$actions$recipe$recipe$var_info$variable
  names(ex_data) <- col_names

  predict(model, ex_data)
})

test_that("plumber", {

  plumb
})

