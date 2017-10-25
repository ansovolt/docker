FROM jupyter/all-spark-notebook

#ADD toree/kernel.json /opt/conda/share/jupyter/kernels/apache_toree_scala/kernel.json
#ADD toree/run.sh /opt/conda/share/jupyter/kernels/apache_toree_scala/bin/run.sh
#USER root
#RUN chmod +x /opt/conda/share/jupyter/kernels/apache_toree_scala/bin/run.sh
#USER jovyan
#RUN mkdir -p /opt/conda/share/jupyter/kernels/spark
#ADD toree/spark/kernel.json /opt/conda/share/jupyter/kernels/spark/kernel.json

ADD hbase-site.xml /usr/local/spark/conf/hbase-site.xml
ADD log4j.properties /usr/local/spark/conf/log4j.properties

RUN mkdir -p /home/jovyan/data
RUN mkdir -p /home/jovyan/notebook

#RUN pip install nbimporter

