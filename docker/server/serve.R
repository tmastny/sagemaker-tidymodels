#!/usr/bin/env Rscript

library(plumber)

source(file.path("/opt/ml/code", input_file))


print('hello starting plumber...')

app <- plumb('plumber.R')
app$run(host = '0.0.0.0', port = 8080)
