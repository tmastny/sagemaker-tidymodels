FROM rocker/r-ver:4.0.0-ubuntu18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpython3-dev \
    python3-dev \
    python3-setuptools \
    python3-pip \
    tzdata

RUN rm -rf /var/lib/apt/lists/*

RUN python3 -m pip --no-cache-dir install sagemaker-training

RUN install2.r --error \
    tidymodels \
    janitor \
    readr \
    recipes \
    plumber \
    optparse

COPY server/serve.R .
COPY server/plumber.R .
COPY server/default_fn.R .

COPY entry .
ENTRYPOINT ["./entry"]
