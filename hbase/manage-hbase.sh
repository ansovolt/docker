#!/bin/bash

set -e

LINK_ROOT_VOLUME_MOUNT_HBASE_DIR="/${ROOT_VOLUME_MOUNT_DIR}/${HBASE_DIR}"

HBASE="hbase"
HBASE_IMAGE="${HBASE}_i"
HBASE_CONTAINER="${HBASE}_c"
REMOTE_HBASE_IMAGE=${DOCKER_HUB_USER}/${HBASE_IMAGE}
HBASE_TAGGED_IMAGE=

init_hbase_image_tag (){	
	HBASE_TAGGED_IMAGE=${REMOTE_HBASE_IMAGE}:${IMAGE_TAG}
}

init_hbase_build(){

	echo "==>Init hbase build..."
	init_hbase_image_tag
	
}

build_hbase_image () {

	init_hbase_build
	echo "==>Building image ${HBASE_TAGGED_IMAGE}..."	
	cd hbase
	docker build -t ${HBASE_TAGGED_IMAGE} .	
	cd ..
}


start_hbase_container () {

	echo "==>Starting container ${HBASE_CONTAINER} do..."

	cd hbase
	docker stop ${HBASE_CONTAINER} &>/dev/null || true
	docker rm ${HBASE_CONTAINER} &>/dev/null || true
	docker run -d --name ${HBASE_CONTAINER} -p 2181:2181 -p 16010:16010 -p 9095:9095 -p 8085:8085 -v ${LINK_ROOT_VOLUME_MOUNT_HBASE_DIR}:/data ${HBASE_TAGGED_IMAGE}
	
	
	cd ..
	sleep 1
}

