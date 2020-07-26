from sagemaker.estimator import Framework
from sagemaker.model import FrameworkModel
from sagemaker.predictor import RealTimePredictor


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
    def __init__(self, **kwargs):
        super(Tidymodels, self).__init__(**kwargs)

    def create_model(self, **kwargs):
        return TidymodelsModel(
            model_data=self.model_data,
            image=self.image_name,
            role=self.role,
            entry_point=self.entry_point,
            **kwargs
        )
