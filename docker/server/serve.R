#!/usr/bin/env Rscript

library(plumber)

test_fn <- function() {print("hello")}

# if I can get this to work, I'll document what i have and move on
input_file <- Sys.getenv("SAGEMAKER_PROGRAM")
print(input_file)
print(getwd())

print("SAGEMAKER_SUBMIT_DIRECTORY")
print(Sys.getenv("SAGEMAKER_SUBMIT_DIRECTORY"))
print(list.files(Sys.getenv("SAGEMAKER_SUBMIT_DIRECTORY")))


print(list.files("/user_module/"))
untar("/user_module/")
print(list.files("/user_module/"))




print(list.files())
print(list.files("/opt/ml/"))
print(list.files("/opt/ml/code/"))

untar("/opt/ml/model/model.tar.gz")
print(list.files("/opt/ml/model/"))


# code actually stored in model.tar.gz?
# https://sagemaker.readthedocs.io/en/stable/frameworks/mxnet/using_mxnet.html#for-versions-1-4-and-higher

source(file.path("/opt/ml/code", input_file))


print('hello starting plumber...')

app <- plumb('plumber.R')
app$run(host = '0.0.0.0', port = 8080)
