#FROM vertx/vertx3


#ENV VERTICLE_HOME vertx
#RUN mkdir -p /vertx
#ADD  gateway/target/fsgw.jar /vertx/gateway.jar
#ADD  uber/target/mapr-streams-vertx-uberdashboard-1.0-SNAPSHOT-sources.jar /vertx/uber.jar
#ADD  run.sh /vertx/run.sh
#RUN chmod +x *.sh
#RUN ls -ltr
#
#ENV VERTICLE_NAME de.bsd.fsgw.MainVerticle
#ENV VERTICLE_FILE /vertx/gateway.jar
#ENV VERTICLE_HOME /vertx
#
#EXPOSE 10080
#
#WORKDIR /vertx
#CMD ["run.sh"]
##ENTRYPOINT ["sh", "-c"]
##CMD ["exec vertx run $VERTICLE_NAME -cp $VERTICLE_HOME/*"]



FROM alpine:3.4

##################
###JAVA
##################
ENV LANG C.UTF-8

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u111
ENV JAVA_ALPINE_VERSION 8.111.14-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

##################
###CUSTOM
##################	
EXPOSE 10080
RUN mkdir -p /vertx

ADD uber/target/mapr-streams-vertx-uberdashboard-1.0-SNAPSHOT-fat.jar /vertx/uber.jar
COPY dashboard/ /vertx/webroot/
ADD run.sh /vertx/run.sh
RUN chmod +x /vertx/run.sh

##################
###START
##################
WORKDIR /vertx
CMD ["java","-cp","uber.jar","com.mapr.demo.Main","web", "10080","ansotopic100"]
