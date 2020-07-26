
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sagemaker-tidymodels

`sagemaker-tidymodels` is an [AWS
Sagemaker](https://aws.amazon.com/sagemaker/) framework for training and
deploy machine learning models written in R.

This framework lets you do cloud-based training and deployment with
[tidymodels](https://www.tidymodels.org/), using the same code you would
write locally.

## Installation

This Python package is not yet available on PyPi. In the meantime, you
can install it from Github:

``` bash
git clone https://github.com/tmastny/sagemaker-tidymodels.git
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
an R script. This R script should process the raw data, train the model,
and save the final fit.

``` python
from sagemaker_tidymodels import Tidymodels, get_role

tidymodels = Tidymodels(
    entry_point="tests/train.R",
    train_instance_type="local",
    role=get_role(),
    image_name="tmastny/sagemaker-tidymodels:latest",
)

s3_data = "s3://sagemaker-sample-data-us-east-2/processing/census/census-income.csv"
tidymodels.fit({"train": s3_data})
```

`train.R` is a normal R script, with a few necessary additions so it can
run on the command line effectively.

``` r
#!/usr/bin/env Rscript

library(tidymodels)

if (sys.nframe() == 0) {

  input_path <- file.path(Sys.getenv('SM_CHANNEL_TRAIN'), "census-income.csv")
  df <- read.csv(input_path, stringsAsFactors = TRUE)


  pipeline <- workflow() %>%
    add_formula(income ~ age) %>%
    add_model(logistic_reg() %>% set_engine("glm"))

  model <- pipeline %>%
    fit(data = df)

  output_path <- file.path(Sys.getenv('SM_MODEL_DIR'), "model.RDS")
  saveRDS(model, output_path)
}
```

1.  The first line should be the shebang `#!/usr/bin/env Rscript`, so it
    can be ran as `./train.R` as required by the framework. Make sure to
    run `chmod +x train.R` so it’s an executable.

2.  All the training logic should be wrapped by the following `if`
    statement. This seems a little mysterious, but it makes sure that
    the training logic doesn’t accidentally run when we’ve deployed our
    model for predictions.

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

From there, you can deploy the model as normal\!

``` python
predictor = model.deploy(initial_instance_count=1, instance_type="local")
predictor.predict(r'28\n')
```

## Advanced Usage

The docker container has some additional features that may be useful.

### Custom Model Serving

The model serving defaults are defined in `docker/server/default_fn.R`.
If you’d like to customize how the model is served, you can overwrite
these defaults by defining these functions in your `entry_point` script.

The valid options are `model_fn`, `input_fn`, `predict_fn`, and
`output_fn`. In our script `basic-train.R`, the default `predict_fn`
means we get class predictors, either `- 50000.` or `50000+.`.

If we wanted to output the probability of belonging to either class, we
could include our own `predict_fn` in `basic-train.R`:

``` r
# add to `train.R`
predict_fn <- function(model, new_data) {
  predict(model, new_data, type = "prob")
}
```

This is also why the training script needs to be wrapped by the `if`
statement.

### Identical Local and Cloud Scripts

In `train.R`, the logic you use to train is exactly the same you would
write locally. However, you can’t run the script locally as is, because
`sagemaker` defines the environment variables `SM_CHANNEL_TRAIN` and
`SM_MODEL_DIR` (as well as [many
others](https://github.com/aws/sagemaker-training-toolkit/blob/397ddea3d1871937dd50dbf36d59b35b182e329b/src/sagemaker_training/params.py#L1-L58)
you might want to use).

A nice way to set some defaults so the script can run both locally and
is sagemaker is by using
[r-optparse](https://github.com/trevorld/r-optparse).

For example:

``` r
library(optparse)

option_list <- list(
  make_option(c("-i", "--input"), default = Sys.getenv("SM_CHANNEL_TRAIN")),
  make_option(c("-o", "--output"), default = Sys.getenv("SM_MODEL_DIR"))
)

args <- parse_args(OptionParser(option_list = option_list))
```

This lets us use `args$input` and `args$output` for the input data path
and output model path if we are running locally or in sagemaker as the
`entry_point`.

Then when running locally, we can define inputs and outputs

``` bash
Rscript tests/train.R -i data/census-income.csv -o models/
```

on the command line so it runs properly.
