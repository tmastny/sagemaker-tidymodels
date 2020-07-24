#!/usr/bin/env Rscript

library(plumber)


print('hello from plumber')

app <- plumb('/opt/ml/plumber.R')
