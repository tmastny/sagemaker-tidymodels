from sagemaker.estimator import Framework
from sagemaker.model import FrameworkModel
from sagemaker.predictor import RealTimePredictor
import subprocess


def get_role(profile="sagemaker"):
    command = "aws configure get role_arn --profile {}".format(profile)
    return (
        subprocess.run(command.split(" "), stdout=subprocess.PIPE,)
        .stdout.decode("utf-8")
        .strip()
    )


class TidymodelsPredictor(RealTimePredictor):
    def __init__(self, endpoint_name, sagemaker_session=None, **kwargs):
        super(TidymodelsPredictor, self).__init__(
            endpoint_name, sagemaker_session=sagemaker_session, **kwargs
        )


class TidymodelsModel(FrameworkModel):

    # `FrameworkModel` accepts a `dependencies` argument to make more code availabe
    # in `/opt/ml/code`: https://github.com/aws/sagemaker-python-sdk/blob/8b2d5c8d73236b59bca6fdcaf96f227a01488288/src/sagemaker/model.py#L704-L712

    __framework_name__ = "tidymodels"

    def __init__(
        self,
        model_data,
        image,
        role,
        entry_point,
        predictor_cls=TidymodelsPredictor,
        **kwargs
    ):
        super(TidymodelsModel, self).__init__(
            model_data, image, role, entry_point, predictor_cls=predictor_cls, **kwargs
        )


class Tidymodels(Framework):
    def __init__(self, entry_point, image_name, role, train_instance_type, **kwargs):
        train_instance_count = kwargs.get("train_instance_count")
        if train_instance_count:
            if train_instance_count != 1:
                raise AttributeError(
                    "Tidymodels does not support distributed training. "
                    "Please remove the 'train_instance_count' argument or set "
                    "'train_instance_count=1' when initializing SKLearn."
                )

        super(Tidymodels, self).__init__(
            entry_point=entry_point,
            image_name=image_name,
            role=role,
            train_instance_type=train_instance_type,
            **dict(kwargs, train_instance_count=1)
        )

    def create_model(self, **kwargs):
        return TidymodelsModel(
            model_data=self.model_data,
            image=self.image_name,
            role=self.role,
            entry_point=self.entry_point,
            **kwargs
        )
