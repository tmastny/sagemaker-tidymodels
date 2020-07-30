from _pytest.outcomes import skip
import pytest

import sys


from sagemaker_tidymodels import (
    Tidymodels,
    TidymodelsModel,
    get_account,
    get_region,
    get_role,
)
from sagemaker.predictor import json_deserializer

s3_training_data = (
    "s3://sagemaker-sample-data-us-east-2/processing/census/census-income.csv"
)
model_data = "s3://sagemaker-{}-{}/sagemaker-tidymodels-2020-07-26-02-38-10-117/model.tar.gz".format(
    get_region(), get_account()
)
ecr_image = "{}.dkr.ecr.{}.amazonaws.com/sagemaker-tidymodels".format(
    get_account(), get_region()
)

with open("tests/example-data.csv") as example_data:
    example_data = example_data.read()


def make_predictor(model, instance_type="local"):
    predictor = model.deploy(initial_instance_count=1, instance_type=instance_type)
    predictor.content_type = "application/json"
    predictor.deserializer = json_deserializer

    return predictor


@pytest.mark.parametrize(
    "entry_point,instance_type,image",
    [
        ("tests/train.R", "local", "sagemaker-tidymodels"),
        ("tests/train-adv.R", "local", "sagemaker-tidymodels"),
        pytest.param(
            "tests/train.R", "ml.m4.xlarge", ecr_image, marks=pytest.mark.slow,
        ),
    ],
)
def test_train(entry_point, instance_type, image):

    tidymodels = Tidymodels(
        entry_point=entry_point,
        train_instance_type=instance_type,
        role=get_role(),
        image_name=image,
    )

    tidymodels.fit({"train": s3_training_data})


@pytest.mark.parametrize(
    "instance_type,image",
    [
        ("local", "sagemaker-tidymodels"),
        pytest.param(
            "ml.t2.medium",
            "tmastny/sagemaker-tidymodels:latest",
            marks=pytest.mark.slow,
        ),
    ],
)
def test_endpoint(instance_type, image):

    model = TidymodelsModel(
        model_data=model_data,
        role=get_role(),
        entry_point="tests/train-adv.R",
        image=image,
    )

    predictor = make_predictor(model, instance_type)
    predicted_value = predictor.predict(example_data)

    predictor.delete_endpoint()

    assert predicted_value == ["- 50000.\n"]


def test_custom_serve_fn(capsys):

    model = TidymodelsModel(
        model_data=model_data,
        role=get_role(),
        entry_point="tests/serve-custom.R",
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


def test_attach_model():
    model = Tidymodels.attach("sagemaker-tidymodels-2020-07-29-02-36-16-054")

    predictor = make_predictor(model)
    predicted_value = predictor.predict("28\n")

    predictor.delete_endpoint()

    assert predicted_value == [" - 50000.\n"]
