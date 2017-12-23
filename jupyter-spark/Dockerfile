FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu16.04

MAINTAINER Anurag Goel <deeprig@anur.ag>

ARG PYTHON_VERSION=2.7
ARG CONDA_PYTHON_VERSION=2
ARG CONDA_VERSION=4.2.12
ARG CONDA_DIR=/opt/conda
ARG TINI_VERSION=v0.13.2
ARG USERNAME=docker
ARG USERID=1000

RUN apt-get update && \
  apt-get install -y --no-install-recommends git wget ffmpeg unzip sudo && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Conda
ENV PATH $CONDA_DIR/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
  wget --quiet https://repo.continuum.io/miniconda/Miniconda$CONDA_PYTHON_VERSION-$CONDA_VERSION-Linux-x86_64.sh -O /tmp/miniconda.sh && \
  echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
  /bin/bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
  rm -rf /tmp/* && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Tini makes notebook kernels work
ADD https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini /tini
RUN chmod +x /tini

# user's home dir should be mapped from EFS
RUN useradd --create-home -s /bin/bash --no-user-group -u $USERID $USERNAME && \
  chown $USERNAME $CONDA_DIR -R && \
  adduser $USERNAME sudo && \
  echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER $USERNAME

WORKDIR /home/$USERNAME

COPY jupyter_notebook_config.py .jupyter/

RUN conda install -y --quiet python=$PYTHON_VERSION && \
  conda install -y --quiet notebook h5py Pillow ipywidgets scikit-learn \
  matplotlib pandas bcolz sympy scikit-image && \
  pip install --upgrade pip && \
  pip install tensorflow-gpu kaggle-cli && \  
  pip install git+git://github.com/fchollet/keras.git@1.1.2 && \
  conda clean -tipsy

RUN conda install -y --quiet mkl-service

ENV CUDA_HOME=/usr/local/cuda
ENV CUDA_ROOT=$CUDA_HOME
ENV PATH=$PATH:$CUDA_ROOT/bin:$HOME/bin
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_ROOT/lib64



#######################SPARK & MESOS########################



USER root

# Spark dependencies
ENV APACHE_SPARK_VERSION 2.0.2
ENV HADOOP_VERSION 2.7
RUN wget --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/server-jre-8u152-linux-x64.tar.gz
RUN mkdir /opt/jdk
RUN tar -zxf server-jre-8u152-linux-x64.tar.gz -C /opt/jdk
RUN ls /opt/jdk
RUN update-alternatives --install /usr/bin/java java /opt/jdk/jdk1.8.0_152/bin/java 100
RUN update-alternatives --install /usr/bin/javac javac /opt/jdk/jdk1.8.0_152/bin/javac 100
RUN update-alternatives --display java


RUN cd /tmp && \
        wget -q http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
        echo "e6349dd38ded84831e3ff7d391ae7f2525c359fb452b0fc32ee2ab637673552a *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha256sum -c - && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

# Mesos dependencies
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E56151BF && \
    DISTRO=debian && \
    CODENAME=jessie && \
    echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-get -y update && \
    apt-get --no-install-recommends -y --force-yes install mesos=0.25.0-0.2.70.debian81 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Spark and Mesos config
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.3-src.zip
ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info


#######################TOREE########################
USER $USERNAME
# Apache Toree kernel
RUN pip --no-cache-dir install https://dist.apache.org/repos/dist/dev/incubator/toree/0.2.0/snapshots/dev1/toree-pip/toree-0.2.0.dev1.tar.gz
RUN jupyter toree install --user




# Jupyter
EXPOSE 8888

RUN mkdir -p /home/$USERNAME/workspace
WORKDIR /home/$USERNAME/workspace

ENTRYPOINT ["/tini", "--"]
CMD jupyter notebook --ip=0.0.0.0 --port=8888



























