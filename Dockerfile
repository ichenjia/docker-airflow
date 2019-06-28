# VERSION 1.10.2
# AUTHOR: Originated Matthieu "Puckel_" Roisil / Forked by Jia "ichenjia" Chen
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t ichenjia/docker-airflow .
# SOURCE: https://github.com/ichenjia/docker-airflow

FROM python:3.6-slim
LABEL maintainer="Puckel_|ichenjia"

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.2
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        freetds-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        libpq-dev \
        git \
    ' \
    && export SLUGIFY_USES_TEXT_UNIDECODE=yes \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        freetds-bin \
        build-essential \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip install 'redis==3.2' \  
    && pip install psycopg2 \
    && pip install psycopg2-binary \
    && pip install absl-py \
    && pip install astor \
    && pip install boto3 \
    && pip install boto \
    && pip install botocore \
    && pip install "bs4==0.0.1" \
    && pip install certifi \
    && pip install chardet \
    && pip install "cssselect==1.0.3" \
    && pip install docutils \
    && pip install "editdistance==0.5.3" \
    && pip install future \
    && pip install gast \
    && pip install "gensim==3.7.3" \
    && pip install google-pasta \
    && pip install "grpcio==1.21.1" \
    && pip install "h5py==2.9.0" \
    && pip install idna \
    && pip install inexactsearch \
    && pip install "jellyfish==0.5.6" \
    && pip install jmespath \
    && pip install "keras-applications==1.0.8" \
    && pip install "keras-preprocessing==1.1.0" \
    && pip install "keras==2.2.4" \
    && pip install lxml \
    && pip install markdown \
    && pip install nameparser \
    && pip install nltk==3.4.3 \
    && pip install numpy \
    && pip install pandas \
    && pip install pathlib \
    && pip install "phonenumbers==8.10.14" \
    && pip install "probableparsing==0.0.1" \
    && pip install probablepeople \
    && pip install protobuf \
    && pip install "py-mini-racer==0.1.18" \
    && pip install "pympler==0.7" \
    && pip install "pyquery==1.4.0" \
    && pip install python-crfsuite \
    && pip install python-dateutil \
    && pip install python-dotenv \
    && pip install python-magic \
    && pip install pytz \
    && pip install pyyaml \
    && pip install requests-file \
    && pip install requests \
    && pip install s3transfer \
    && pip install "scipy==1.3.0" \
    && pip install selenium \
    && pip install silpa-common \
    && pip install six \
    && pip install smart-open \
    && pip install "soundex==1.1.3" \
    && pip install "spacy==2.1.4" \
    && pip install "spellchecker==0.4" \
    && pip install "tensorboard==1.14.0" \
    && pip install "tensorflow-estimator==1.14.0" \
    && pip install "tensorflow==1.14.0" \
    && pip install termcolor \
    && pip install "tldextract==2.2.1" \
    && pip install urllib3 \
    && pip install "us==1.0.0" \
    && pip install "usaddress==0.5.10" \
    && pip install vobject \
    && pip install werkzeug \
    && pip install wrapt \
    && pip install pattern3 \
    && python -m spacy download en_core_web_sm \
    && python -m spacy download en_core_web_lg \
    && pip install kmodes \
    && pip install matplotlib \
    && pip install sklearn \    
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

RUN chown -R airflow: ${AIRFLOW_USER_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"] # set default arg for entrypoint
