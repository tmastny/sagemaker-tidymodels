#!/usr/bin/env Rscript

library(plumber)

source("default_fn.R")
source(file.path("/opt/ml/code", Sys.getenv("SAGEMAKER_PROGRAM")))


app <- plumb('plumber.R')
app$run(host = '0.0.0.0', port = 8080)
