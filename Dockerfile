FROM rocker/r-ver:4.0.0-ubuntu18.04

RUN install2.r --error \
    tidymodels \
    janitor

COPY R/Untitled.R /opt/ml/code/

# ENTRYPOINT ["/bin/sh -c", "/opt/ml/code/Untitled.R"]
ENTRYPOINT ["/usr/local/bin/Rscript", "/opt/ml/code/Untitled.R"]
