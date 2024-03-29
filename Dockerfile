# DESCRIPTION: Airflow container

FROM python:3.6-slim

# Never prompts the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.0
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_GPL_UNIDECODE yes
ENV AIRFLOW_HOME=${AIRFLOW_HOME}

# Set proper python path for application to resolve dependencies
ENV PYTHONPATH=/usr/local/airflow/

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

RUN set -ex \
    && buildDeps=' \
        python3-dev \
        libkrb5-dev \
        libsasl2-dev \
        libssl-dev \
        libffi-dev \
        build-essential \
        libblas-dev \
        liblapack-dev \
        libpq-dev \
        git \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        python3-pip \
        python3-requests \
        default-libmysqlclient-dev \
        apt-utils \
        curl \
        rsync \
        netcat \
        locales \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_HOME} airflow \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[crypto,celery,postgres,hive,jdbc,mysql,ssh${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && pip install celery[redis]==4.1.1 \
    && pip install virtualenv \
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

WORKDIR ${AIRFLOW_HOME}

# Copy configurations
COPY scripts/entrypoint.sh /entrypoint.sh
COPY airflow/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

# Copy Dags
RUN mkdir ${AIRFLOW_HOME}/dags
COPY airflow/dags ${AIRFLOW_HOME}/dags/

# Copy app requirements first and install to speed up docker image generation
COPY app/requirements.txt ${AIRFLOW_HOME}/app/requirements.txt
WORKDIR ${AIRFLOW_HOME}/app
RUN pip install -r requirements.txt

# Copy app code and set access permissions
COPY app ${AIRFLOW_HOME}/app
RUN chown -R airflow: ${AIRFLOW_HOME}

# Expose airflow ports
EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${PYTHONPATH}
ENTRYPOINT ["sh","/entrypoint.sh"]

# Set default arg for entrypoint
CMD ["webserver"]
