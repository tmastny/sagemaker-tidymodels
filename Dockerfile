FROM rocker/r-ver:4.0.0-ubuntu18.04

RUN install2.r --error \
    tidymodels \
    janitor

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpython3-dev \
    python3-dev \
    python3-pip

RUN rm -rf /var/lib/apt/lists/*

RUN python3 -m pip --no-cache-dir install setuptools

RUN python3 -m pip --no-cache-dir install sagemaker-training

RUN install2.r --error \
    readr

RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata

RUN install2.r --error \
    recipes \
    plumber


# COPY train .
#
# copy R/serve.R serve.R
# COPY serve .
# COPY R/Untitled.R /opt/ml/code/

# ENTRYPOINT ["/bin/sh -c", "/opt/ml/code/Untitled.R"]
# ENTRYPOINT ["/usr/local/bin/Rscript", "/opt/ml/code/Untitled.R"]
