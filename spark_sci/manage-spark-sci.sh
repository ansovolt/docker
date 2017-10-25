#!/bin/bash

set -e

LINK_ROOT_VOLUME_MOUNT_SPARK_SCI_DIR="/${ROOT_VOLUME_MOUNT_DIR}/${SPARK_SCI_DIR}"

SPARK_SCI="spark_sci"
SPARK_SCI_IMAGE="${SPARK_SCI}_i"
SPARK_SCI_CONTAINER="${SPARK_SCI}_c"
REMOTE_SPARK_SCI_IMAGE=${DOCKER_HUB_USER}/${SPARK_SCI_IMAGE}
SPARK_SCI_TAGGED_IMAGE=

init_spark_sci_image_tag (){	
	SPARK_SCI_TAGGED_IMAGE=${REMOTE_SPARK_SCI_IMAGE}:${IMAGE_TAG}
}

init_spark_sci_build(){
	echo "==>Init spark sci build..."
	init_spark_sci_image_tag
}

build_spark_sci_image () {

	init_spark_sci_build
	echo "==>Building image ${SPARK_SCI_TAGGED_IMAGE}..."	
	cd spark_sci
	docker build -t ${SPARK_SCI_TAGGED_IMAGE} .	
	cd ..
}

start_spark_sci_container () {

	echo "==>Starting container ${SPARK_SCI_CONTAINER} ..."

	cd spark_sci
	docker stop ${SPARK_SCI_CONTAINER} &>/dev/null || true
	docker rm ${SPARK_SCI_CONTAINER} &>/dev/null || true
	
	
	docker run -d --name ${SPARK_SCI_CONTAINER} -p 7580:7580 -v ${LINK_ROOT_VOLUME_MOUNT_SPARK_SCI_DIR}/notebook:/opt/zeppelin/notebook -v ${LINK_ROOT_VOLUME_MOUNT_SPARK_SCI_DIR}/data:/opt/zeppelin/data  ${SPARK_SCI_TAGGED_IMAGE}
	
	
	cd ..
	sleep 1
}

