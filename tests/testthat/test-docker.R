library(readr)
library(sagemaker)

test_that("docker executes", {
  d <- read_s3(
    's3://sagemaker-sample-data-us-east-2/processing/census/census-income.csv',
    col_names = TRUE,
    trim_ws = TRUE
  )

  d
})

