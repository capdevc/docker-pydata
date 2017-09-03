FROM jupyter/scipy-notebook:latest
MAINTAINER Cristian Capdevila dockerconda@defvar.org

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
    awscli \
    boto3 \
    pytables \
    cytoolz \
    toolz \
    yapf \
    ujson \
    unicodecsv \
    tqdm \
    theano \
    tensorflow \
    tabulate \
    jupyter_contrib_nbextensions \
    xgboost \
    pymc3 && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR

# Install imbalanced learn from it's channel
RUN conda install --quiet --yes -c glemaitre imbalanced-learn

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

WORKDIR /home/jovyan/analysis

# Install packages that depend on statsmodels, without clobbering our custom
# install.
RUN conda install --yes  --no-deps seaborn category_encoders
