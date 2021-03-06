## Description

This repository contains a docker image built ftom [continuumio/anaconda3](https://hub.docker.com/r/continuumio/anaconda3/)

## Packages

In addition to those included in the base image, I have added:

 - [tensorflow](https://github.com/tensorflow/tensorflow) (CPU Only)
 - [awscli](https://github.com/aws/aws-cli)
 - [boto3](https://github.com/boto/boto3)
 - [dask](https://github.com/dask/dask)
 - [pyarrow](https://arrow.apache.org/)
 - [tqdm](https://github.com/noamraph/tqdm)
 - [tabulate](https://bitbucket.org/astanin/python-tabulate)
 - [cytoolz](https://github.com/pytoolz/cytoolz)
 - [theano](https://github.com/Theano/Theano) (For PyMC3)
 - [pymc3](https://github.com/pymc-devs/pymc3)
 - [xgboost](https://github.com/dmlc/xgboost/tree/master/python-package)
 - [lightgbm](https://github.com/Microsoft/LightGBM)
 - [imbalanced-learn](https://github.com/scikit-learn-contrib/imbalanced-learn)
 - [yellowbrick](https://github.com/DistrictDataLabs/yellowbrick)
 - [eli5](https://github.com/TeamHG-Memex/eli5)
 - [lime](https://github.com/marcotcr/lime)
 - [ml_insights](https://github.com/numeristical/introspective)

## Usage

Since the image autoruns the notebook server and I want to set some things up beforehand, I have some zsh aliases to actually run the container:

```
# Start the contianer
function dpu () {
    if [[ "$DOCKER_MACHINE_NAME" == "dsec2" ]]; then
        # We're running on a docker-machine AWS instance. I'll have to copy data over.
        docker run --name=jupyter --rm -t -d -p 8888:8888 -v /tmp:/home/jovyan/joblib capdevc/pydata:latest start.sh sleep infinity && \
        docker cp $HOME/.aws jupyter:home/jovyan/.aws && \
        docker exec -it --user root jupyter chown -R jovyan:users /home/jovyan/.aws/ && \
        docker cp $HOME/analysis jupyter:home/jovyan/analysis && \
        docker exec -it --user root jupyter chown -R jovyan:users /home/jovyan/analysis/ && \
        docker exec -it -e "JOBLIB_TEMP_FOLDER=/home/jovyan/joblib" jupyter start-notebook.sh
    else
        # Running locally.
        docker run --name=jupyter --rm -t -d -p 8888:8888 -v /tmp:/home/jovyan/joblib -v $HOME/analysis:/home/jovyan/analysis \
               capdevc/pydata:latest start.sh sleep infinity && \
        docker cp $HOME/.aws jupyter:/home/jovyan/.aws && \
        docker exec -it --user root jupyter chown -R jovyan:users /home/jovyan/.aws/ && \
        docker exec -it -e "JOBLIB_TEMP_FOLDER=/home/jovyan/joblib" jupyter start-notebook.sh
    fi
}

# Stop the containerfunction dpd() {
    if [[ "$DOCKER_MACHINE_NAME" == "dsec2" ]]; then
        # We're on AWS so copy the data back.
        docker cp jupyter:home/jovyan/analysis $HOME/analysis-dled && \
        docker kill jupyter
     else
        docker kill jupyter
     fi
}

```

This erases the container after it shuts down, and also maps the joblib temp directory to /tmp on the host machine.
