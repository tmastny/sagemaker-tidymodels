.PHONY: lint test test-local test-integration

lint:
	black .

test-local: tests/test_local_instance.py tests/advanced-train.R
	pytest tests/test_local_instance.py

test-integration: tests/basic-train.R tests/basic_tidymodels_example.py
	pytest tests/test_integration.py

test:
	test-local
	test-integration

README.md: README.Rmd tests/basic-train.R tests/basic_tidymodels_example.py
	Rscript -e "rmarkdown::render('README.Rmd')"
