#!/usr/bin/env python

import os
import sys
import setuptools

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup


if sys.argv[-1] == "publish":
    os.system("python setup.py sdist upload")
    sys.exit()

readme = open("README.md").read()
requirements = open("requirements.txt").read()

setup(
    name="sagemaker-tidymodels",
    version="0.1.0",
    description="Sagemaker framework for Tidymodels",
    long_description=readme,
    long_description_content_type="text/markdown",
    author="Timothy Mastny",
    author_email="tim.mastny@gmail.com",
    url="https://github.com/tmastny/sagemaker-tidymodels",
    packages=setuptools.find_packages(),
    include_package_data=True,
    install_requires=requirements,
    license="MIT",
    zip_safe=False,
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Natural Language :: English",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.6",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.3",
        "Programming Language :: Python :: Implementation :: PyPy",
    ],
)
