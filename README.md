## Description

This repository contains a docker image built ftom [continuumio/anaconda3](https://hub.docker.com/r/continuumio/anaconda3/)

## Packages

In addition to those included in the base image, I have added:

 - [tensorflow](https://github.com/tensorflow/tensorflow) (CPU Only)
 - [awscli](https://github.com/aws/aws-cli)
 - [boto3](https://github.com/boto/boto3)
 - [tqdm](https://github.com/noamraph/tqdm)
 - [tabulate](https://bitbucket.org/astanin/python-tabulate)
 - [theano](https://github.com/Theano/Theano) (For PyMC3)
 - [pymc3](https://github.com/pymc-devs/pymc3)
 - [xgboost](https://github.com/dmlc/xgboost/tree/master/python-package)

## Usage

I run the image like so:

```
docker run --rm -t -d -p 8888:8888 -v /tmp:/home/jovyan/joblib capdevc/pydata:latest
```

This erases the container after it shuts down, and also maps the joblib temp directory to /tmp on the host machine.
