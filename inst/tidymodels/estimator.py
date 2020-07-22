from sagemaker.estimator import Framework
from sagemaker.model import FrameworkModel
from sagemaker.predictor import RealTimePredictor


class TidyModels(FrameworkModel):
    def __init__(self, model_data, role, entry_point, image=None):
        # todo: prepend `entry_point` with `"Rscript "`
        pass


class TidyModelsPredictor(RealTimePredictor):
    def __init__(self):
        # todo: customer serializers
        pass
