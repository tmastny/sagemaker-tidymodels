
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sagemaker-tidymodels

`sagemaker-tidymodels` is an [AWS
Sagemaker](https://aws.amazon.com/sagemaker/) framework for training and
deploy machine learning models written in R.

This framework lets you use the same
[tidymodels](https://www.tidymodels.org/) script in development to
cloud-based training and deployment.

## Installation

This Python package is not yet available on PyPi. In the meantime, you
can install it from Github:

``` bash
https://github.com/tmastny/sagemaker-tidymodels.git
pip install sagemaker-tidymodels/
```

The docker image is hosted on
[dockerhub](https://hub.docker.com/repository/docker/tmastny/sagemaker-tidymodels),
or you can pull directly with

``` bash
docker pull tmastny/sagemaker-tidymodels
```

## Usage

The `sagemaker-tidymodels` Python package provides simple wrappers
around the
[Estimator](https://sagemaker.readthedocs.io/en/stable/api/training/estimators.html)
and Model `sagemaker` classes.

The main difference is the `entry_point` parameter, where you can supply
an R script. This R script should encompass your end-to-end training.

``` python
from sagemaker_tidymodels import Tidymodels

tidymodels = Tidymodels(
    entry_point="train.R",
    train_instance_type="local",
    role=role,
    image_name="sagemaker-tidymodels",
)

s3_data <- "s3://sagemaker-sample-data-us-east-2/processing/census/census-income.csv"
tidymodels.fit({'train': s3_data})
```

`train.R` is a normal R script, with a few necessary additions so it can
run on the command line effectively.

``` r
#!/usr/bin/env Rscript

library(tidymodels)
library(readr)

if (sys.nframe() == 0) {

  input_path <- file.path(Sys.getenv('SM_CHANNEL_TRAIN'), "census-income.csv")
  df <- read_csv(input_path, trim_ws = TRUE)

  df <- read_csv("data/census-income.csv")
  df

  pipeline <- workflow() %>%
    add_formula(`wage per hour` ~ age) %>%
    add_model(linear_reg() %>% set_engine("lm"))

  model <- pipeline %>%
    fit(data = df)

  output_path <- file.path(Sys.getenv('SM_MODEL_DIR'), "model.RDS")
  saveRDS(model, output_path)
}
```

1.  The first line should be the shebang `#!/usr/bin/env Rscript`, so it
    can be ran as `./train.R` as required by the framework.

2.  All the training logic should be wrapped by the following `if`
    statement. This seems a little mysterious, but it makes sure that
    the training logic doesn’t accidentally run when we’ve deployed our
    model for predictions. See advanced usage below for more details.

<!-- end list -->

``` r
if (sys.nframe() == 0) {
  # training logic goes here!
}
```

3.  Sagemaker is very specific about input and output locations. The
    input data path is found in an environment variable that can be read
    using `Sys.getenv('SM_CHANNEL_TRAIN')`. Likewise, the output model
    path can be found with `Sys.getenv('SM_MODEL_DIR')`.
