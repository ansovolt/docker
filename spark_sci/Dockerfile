FROM debian:jessie


#################
## LOCALS
#################
RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* 


ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

#################
## TOOLS
#################
RUN apt-get update \
 && apt-get install -y curl unzip \
 && apt-get install -y vim \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
 
 
#################
## JAVA
#################
#ENV JAVA_HOME /usr/jdk1.8.0_144
ENV JAVA_HOME /usr/jdk1.8.0_152
ENV PATH $PATH:$JAVA_HOME/bin
#RUN curl -sL --retry 3 --insecure \
#  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
#  "http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.tar.gz" \
#  | gunzip \
#  | tar x -C /usr/ 

RUN curl -sL --retry 3 --insecure \
  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
  "http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/server-jre-8u152-linux-x64.tar.gz" \
  | gunzip \
  | tar x -C /usr/ 
  
#################
## SPARK
#################
ENV SPARK_VERSION 2.1.0
ENV HADOOP_VERSION 2.7
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV PATH $PATH:${SPARK_HOME}/bin
RUN curl -sL --retry 3 \
  "http://d3kbcqa49mib13.cloudfront.net/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
  && mv /usr/$SPARK_PACKAGE $SPARK_HOME
WORKDIR $SPARK_HOME

#################
##Zeppelin
#################
ENV Z_HOME /opt/zeppelin
RUN mkdir -p ${Z_HOME}/data
RUN mkdir -p /hbase/conf

ADD zeppelin-0.7.2-bin-all ${Z_HOME}


#################
##VOLUMES
#################
VOLUME ["/opt/zeppelin/data"]
VOLUME ["/opt/zeppelin/notebook"]

#################
##START
#################
WORKDIR ${Z_HOME}
RUN chmod +x bin/*.sh
CMD ["bin/zeppelin.sh"]
