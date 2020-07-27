lint:
	black .

docker-build:
	docker build docker/ -t sagemaker-tidymodels

test-local:
	pytest tests/test_local_instance.py

test-integration:
	pytest tests/test_integration.py

test: | test-local test-integration

publish: | lint docker-build test

README.md: README.Rmd tests/train.R tests/train.py
	Rscript -e "rmarkdown::render('README.Rmd', run_pandoc = FALSE)"
	mv README.knit.md README.md

package:
	python setup.py sdist bdist_wheel;
	twine upload dist/*
