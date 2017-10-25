#!/bin/bash

set -e

LINK_ROOT_VOLUME_MOUNT_SPARK_DIR="/${ROOT_VOLUME_MOUNT_DIR}/${SPARK_DIR}"

SPARK="spark"
SPARK_IMAGE="${SPARK}_i"
SPARK_CONTAINER="${SPARK}_c"
REMOTE_SPARK_IMAGE=${DOCKER_HUB_USER}/${SPARK_IMAGE}
SPARK_TAGGED_IMAGE=

init_spark_image_tag (){	
	SPARK_TAGGED_IMAGE=${REMOTE_SPARK_IMAGE}:${IMAGE_TAG}
}

init_spark_build(){

	echo "==>Init spark build..."
	init_spark_image_tag
	
}

build_spark_image () {

	init_spark_build
	echo "==>Building image ${SPARK_TAGGED_IMAGE}..."	
	cd spark
	docker $(cfg) build -t ${SPARK_TAGGED_IMAGE} .	
	cd ..
}


start_spark_container () {

	echo "==>Starting container ${SPARK_CONTAINER} do..."

	cd spark
	docker $(cfg) stop ${SPARK_CONTAINER} &>/dev/null || true
	docker $(cfg) rm ${SPARK_CONTAINER} &>/dev/null || true
	docker run -d -p 8888:8888 -v ${LINK_ROOT_VOLUME_MOUNT_SPARK_DIR}/data:/home/docker/data -v ${LINK_ROOT_VOLUME_MOUNT_SPARK_DIR}/ntbs:/home/docker --name ${SPARK_CONTAINER} ${SPARK_TAGGED_IMAGE}	
	
	cd ..
	sleep 1
}

