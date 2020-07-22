#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)
print(args)

if (args == 'train') {
  print('hello train')
} else{
  print('goodbye no train')
}
