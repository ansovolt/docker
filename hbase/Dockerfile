# HBase in Docker
#
# Version 0.3

# http://docs.docker.io/en/latest/use/builder/

FROM ubuntu:xenial
MAINTAINER Dave Beckett <dave@dajobe.org>

COPY *.sh /build/
RUN chmod +x /build/*.sh


ENV HBASE_VERSION 1.2.4
#this is the version that Zeppelin supports for hbase shell
#ENV HBASE_VERSION 1.0.1.1

RUN /build/prepare-hbase.sh && \
    cd /opt/hbase && /build/build-hbase.sh \
    cd / && /build/cleanup-hbase.sh && rm -rf /build

VOLUME /data

ADD ./hbase-site.xml /opt/hbase/conf/hbase-site.xml

ADD ./zoo.cfg /opt/hbase/conf/zoo.cfg

ADD ./replace-hostname /opt/replace-hostname
RUN chmod +x /opt/replace-hostname

ADD ./hbase-server /opt/hbase-server
RUN chmod +x /opt/hbase-server

# REST API
EXPOSE 8080
# REST Web UI at :8085/rest.jsp
EXPOSE 8085
# Thrift API
EXPOSE 9090
# Thrift Web UI at :9095/thrift.jsp
EXPOSE 9095
# HBase's Embedded zookeeper cluster
#EXPOSE 2181
# HBase Master web UI at :16010/master-status;  ZK at :16010/zk.jsp
EXPOSE 16010

EXPOSE 60030
EXPOSE 60020
EXPOSE 60010
EXPOSE 60000

CMD ["/opt/hbase-server"]
