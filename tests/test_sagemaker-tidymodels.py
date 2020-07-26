from os import supports_bytes_environ
import subprocess

import sagemaker
from sagemaker_tidymodels import Tidymodels, TidymodelsModel
from sagemaker.predictor import json_deserializer

s3_training_data = (
    "s3://sagemaker-sample-data-us-east-2/processing/census/census-income.csv"
)

role = (
    subprocess.run(
        "aws configure get role_arn --profile sagemaker".split(" "),
        stdout=subprocess.PIPE,
    )
    .stdout.decode("utf-8")
    .strip()
)


def test_local_train():
    tidymodels = Tidymodels(
        entry_point="tests/advanced-train.R",
        train_instance_type="local",
        role=role,
        image_name="sagemaker-tidymodels",
    )

    tidymodels.fit({"train": s3_training_data})


with open("tests/example-data.csv") as example_data:
    example_data = example_data.read()


def test_local_endpoint():
    model_data = "s3://sagemaker-us-east-2-495577990003/sagemaker-tidymodels-2020-07-26-02-38-10-117/model.tar.gz"
    source_dir = "s3://sagemaker-us-east-2-495577990003/sagemaker-tidymodels-2020-07-26-02-38-10-117/source/sourcedir.tar.gz"

    model = TidymodelsModel(
        model_data=model_data,
        role=role,
        entry_point="tests/advanced-train.R",
        source_dir=source_dir,
        image="sagemaker-tidymodels",
    )

    predictor = model.deploy(initial_instance_count=1, instance_type="local")
    predictor.content_type = "application/json"
    predictor.deserializer = json_deserializer

    predicted_value = predictor.predict(example_data)

    predictor.delete_endpoint()

    assert predicted_value == ["- 50000.\n"]

## TODO:
##   add test with custom serve functions

## TODO:
##   integration test with dockerhub
