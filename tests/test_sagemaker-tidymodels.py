from os import supports_bytes_environ
import subprocess
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
        entry_point="tests/train.R",
        train_instance_type="local",
        role=role,
        image_name="sagemaker-tidymodels",
    )

    tidymodels.fit({"train": s3_training_data})


example_data = r"73,Not in universe,0,0,High school graduate,0,Not in universe,Widowed,Not in universe or children,Not in universe,White,All other,Female,Not in universe,Not in universe,Not in labor force,0,0,0,Nonfiler,Not in universe,Not in universe,Other Rel 18+ ever marr not in subfamily,Other relative of householder,1700.09,?,?,?,Not in universe under 1 year old,?,0,Not in universe,United-States,United-States,United-States,Native- Born in the United States,0,Not in universe,2,0,95,- 50000.\n"


def test_local_endpoint():
    model_data = "s3://sagemaker-us-east-2-495577990003/sagemaker-tidymodels-2020-07-26-02-38-10-117/model.tar.gz"
    source_dir = "s3://sagemaker-us-east-2-495577990003/sagemaker-tidymodels-2020-07-26-02-38-10-117/source/sourcedir.tar.gz"

    model = TidymodelsModel(
        model_data=model_data,
        role=role,
        entry_point="tests/train.R",
        source_dir=source_dir,
        image="sagemaker-tidymodels",
    )

    predictor = model.deploy(initial_instance_count=1, instance_type="local")
    predictor.content_type = "application/json"
    predictor.deserializer = json_deserializer

    assert predictor.predict(example_data) == ["- 50000.\n"]
