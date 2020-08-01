lint:
	black .

docker-build:
	docker build docker/ -t sagemaker-tidymodels

test-local:
	pytest tests/test_framework.py --skipslow

test:
	pytest tests/

final: | lint docker-build test

README.md: README.Rmd tests/train.R tests/train.py
	Rscript -e "rmarkdown::render('README.Rmd', run_pandoc = FALSE)"
	mv README.knit.md README.md

package:
	rm -f dist/*
	python setup.py sdist bdist_wheel;
	twine upload dist/*

ecr:
	sh docker/push-to-ecr.sh
