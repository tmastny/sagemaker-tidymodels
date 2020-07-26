from sagemaker_tidymodels import Tidymodels, get_role

tidymodels = Tidymodels(
    entry_point="tests/train.R",
    train_instance_type="local",
    role=get_role(),
    image_name="tmastny/sagemaker-tidymodels:latest",
)

s3_data = "s3://sagemaker-sample-data-us-east-2/processing/census/census-income.csv"
tidymodels.fit({"train": s3_data})
