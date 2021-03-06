FROM jupyter/scipy-notebook:ae885c0a6226
MAINTAINER Cristian Capdevila ccapdevila@prognos.ai

# Change the default jupyter notebook cell width
RUN mkdir -p /home/jovyan/.jupyter/custom/ && \
    echo '.container { width:88% !important; }' >> /home/jovyan/.jupyter/custom/custom.css

# Specify a mounted volume for joblib to use as temp space
# If you don't do this it will quickly fill disk
# https://www.kaggle.com/general/22023
RUN mkdir $HOME/joblib
VOLUME ["$HOME/joblib"]

# Install packages I use
RUN conda install --quiet --yes \
    awscli=1.11.120 \
    boto3=1.4.7 \
    boto=2.48.0 \
    s3fs=0.1.2 \
    dask=0.15.4 \
    distributed=1.19.3 \
    pytables=3.4.2 \
    pyarrow=0.7.1 \
    cytoolz=0.8.2 \
    toolz=0.8.2 \
    yapf=0.17.0 \
    ujson=1.35 \
    unicodecsv=0.14.1 \
    tqdm=4.19.4 \
    theano=0.9.0 \
    tensorflow=1.3.0 \
    tabulate=0.8.1 \
    jupyter_contrib_nbextensions=0.3.3 \
    lightgbm=2.0.10 \
    pymc3=3.2 \
    eli5=0.8 \
    mkl-service=1.1.2 && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR

# Install imbalanced learn from its channel
RUN conda install --quiet --yes -c glemaitre imbalanced-learn=0.3.1

# Install yellowbrick from its channel
RUN conda install --quiet --yes -c districtdatalabs yellowbrick=0.5

# Turn on jupyter extensions
RUN jupyter contrib nbextension install --sys-prefix
RUN jupyter nbextension enable collapsible_headings/main && \
    jupyter nbextension enable spellchecker/main && \
    jupyter nbextension enable datestamper/main && \
    jupyter nbextension enable execute_time/ExecuteTime && \
    jupyter nbextension enable runtools/main && \
    jupyter nbextension install https://github.com/jfbercher/yapf_ext/archive/master.zip --user && \
    jupyter nbextension enable yapf_ext-master/yapf_ext && \
    jupyter nbextensions_configurator enable

# There's currently a bug in the statsmodels MICE implementation w/ numpy 1.13
# so we need to install from master. This also means we need to spin seaborn
# since it depends on statsmodels and breaks if you don't reinstall.
run conda uninstall --quiet --yes statsmodels seaborn
RUN git clone https://github.com/statsmodels/statsmodels.git
WORKDIR /home/jovyan/statsmodels
RUN python setup.py build
RUN python setup.py install
RUN python setup.py clean

# Install xgboost from github
RUN git clone --recursive https://github.com/dmlc/xgboost && \
    cd xgboost && \
    make -j4 && \
    cd python-package; python setup.py install

WORKDIR /home/jovyan

# Install packages that depend on statsmodels, without clobbering our custom
# install.
RUN conda install --yes  --no-deps seaborn=0.8.1 category_encoders=1.2.4


# Install things only on pypi
RUN pip install \
    lime==0.1.1.25 \
    ml_insights==0.0.17
