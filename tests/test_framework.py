from _pytest.outcomes import skip
import pytest

import sys
import subprocess
import tempfile

from sagemaker_tidymodels import Tidymodels, TidymodelsModel, get_role
from sagemaker.predictor import json_deserializer

s3_training_data = (
    "s3://sagemaker-sample-data-us-east-2/processing/census/census-income.csv"
)
model_data = "s3://sagemaker-us-east-2-495577990003/sagemaker-tidymodels-2020-07-26-02-38-10-117/model.tar.gz"

with open("tests/example-data.csv") as example_data:
    example_data = example_data.read()


def make_predictor(model, instance_type="local"):
    predictor = model.deploy(initial_instance_count=1, instance_type=instance_type)
    predictor.content_type = "application/json"
    predictor.deserializer = json_deserializer

    return predictor


@pytest.mark.parametrize(
    "train_instance_type",
    ["local", pytest.param("ml.m4.xlarge", marks=pytest.mark.slow)],
)
@pytest.mark.parametrize("entry_point", ["tests/train.R", "tests/train-adv.R"])
def test_trainining(entry_point, train_instance_type):
    tidymodels = Tidymodels(
        entry_point=entry_point,
        train_instance_type=train_instance_type,
        role=get_role(),
        image_name="sagemaker-tidymodels",
    )

    tidymodels.fit({"train": s3_training_data})


@pytest.mark.parametrize(
    "instance_type",
    ["local", pytest.param("ml.t2.medium", marks=pytest.mark.slow)],
)
def test_endpoint(instance_type):

    model = TidymodelsModel(
        model_data=model_data,
        role=get_role(),
        entry_point="tests/train-adv.R",
        image="sagemaker-tidymodels",
    )

    predictor = make_predictor(model, instance_type)
    predicted_value = predictor.predict(example_data)

    predictor.delete_endpoint()

    assert predicted_value == ["- 50000.\n"]


def test_custom_serve_fn(capsys):

    _, temp_train = tempfile.mkstemp()

    with open(temp_train, "w") as file:
        subprocess.run(["cat", "tests/serve-custom.R", "tests/train.R"], stdout=file)

    model = TidymodelsModel(
        model_data=model_data,
        role=get_role(),
        entry_point=temp_train,
        image="sagemaker-tidymodels",
    )

    predictor = make_predictor(model)
    _ = predictor.predict(example_data)

    predictor.delete_endpoint()

    out, err = capsys.readouterr()
    sys.stdout.write(out)
    sys.stderr.write(err)

    assert "__custom-model_fn__" in out
    assert "__custom-input_fn__" in out
    assert "__custom-predict_fn__" in out
    assert "__custom-output_fn__" in out


@pytest.mark.slow
def test_dockerhub_readme_example():
    import tests.train
