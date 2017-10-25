#!/bin/bash


set -e

#echo "Sourcing..."
#source setenv.sourceme


DOCKER_VBOX_DRIVER="virtualbox"

APP_NAME="docker"

DOCKER_HOST_NAME=
DOCKER_IP=
IMAGE_TAG=1

SPARK_NOTEBOOK="sparknotebook"
SPARK_NOTEBOOK_IMAGE="${REDIS}_i"
SPARK_NOTEBOOK_CONTAINER="${REDIS}_c"
REMOTE_SPARK_NOTEBOOK_IMAGE=${DOCKER_HUB_USER}/${SPARK_NOTEBOOK_IMAGE}
SPARK_NOTEBOOK_TAGGED_IMAGE=


#Helper functions
set_host_default () {
    

    cmd="eval $(docker-machine env ${DOCKER_HOST_NAME})"
	echo "${cmd}"
	${cmd}
    
	#$(docker-machine env $(docker-machine active))
	
    #if [[ ! -e /var/run/docker.sock ]]; then
    #    #$(docker-machine env $(docker-machine active))
	#	docker-machine env ${DOCKER_HOST_NAME}
    #fi

    
}

cfg () {
    echo $(docker-machine config ${DOCKER_HOST_NAME})
}

build_image () {
	cmd="docker build -t ${SPARK_NOTEBOOK_TAGGED_IMAGE} ."
	echo "Running ${cmd}"
	#docker build -t ${SPARK_NOTEBOOK_TAGGED_IMAGE} .	
	${cmd}
}


start_container () {

	echo "Starting jenkins container ${JENKINS_CONTAINER} do..."

	docker stop ${SPARK_NOTEBOOK_CONTAINER} &>/dev/null || true
	docker rm ${SPARK_NOTEBOOK_CONTAINER} &>/dev/null || true
	docker run -d --name ${SPARK_NOTEBOOK_CONTAINER} 
	sleep 1
}


shutdown_container () {

	echo "Stopping ${KIBANA_CONTAINER}"
	docker $(cfg) stop ${KIBANA_CONTAINER} &>/dev/null || true

}


print_usage(){
	echo "Usage: manage.sh [up {driver} | down {driver} | deploy {driver} {tag}]"
}

init_image_tag(){
	REDIS_TAGGED_IMAGE=${REMOTE_REDIS_IMAGE}:${IMAGE_TAG}
}


init_build(){

	echo "Copying ear file..."	
	cp ../../incentive-hub-service.ear/target/IncentiveHubService.ear wildfly/IncentiveHubService.ear	
	echo "Done copying ear file..."

	echo "Copying dashboard..."
	cd web		
	rm -rf posengine	
	cp -R ../../../dashboard/pose/posengine ../../../docker/inhub-dev-env/web/posengine	
	cd ..		
	sed -i  "s/asochal/${DOCKER_IP}/g" ../../docker/inhub-dev-env/web/posengine/assets/js/app/appConfig.js		
	
	echo "Done copying dashboard..."

	echo "Copying database scripts..."
	cd postgres/postgres_setup		
	rm -rf *.sql
	rm -rf *.log
	
	cp  ../../../../database/consolidated/* ../../../../docker/inhub-dev-env/postgres/postgres_setup
	
	cd ../..
	echo "Done copying database scripts..."
	

	#echo ${IMAGE_TAG} > current.tag

}

build_app(){	
	init_build
	init_image_tag
	
	build_redis_image
	build_rabbitmq_image
	build_postgres_image
	build_wildfly_image
	build_web_image
    
	#build_elasticsearch_image
	#build_syslogng_image
		
	#build_kibana_image
}


build_jenkins(){		
	init_image_tag	
	build_jenkins_image
}


start_app(){
	init_image_tag
	
	start_redis_container
	start_rabbitmq_container
	start_postgres_container


	#start_elasticsearch_container
	#start_syslogng_container
	
	start_wildfly_container	
	start_web_container	
	
	#start_kibana_container

}




start_jenkins(){
	init_image_tag
	start_jenkins_container
}


deploy_static(){
	echo "Deploying static content..."	
	rm -rf ${ROOT_VOLUME_MOUNT_DIR}/apache/htdocs/posengine		
	cp -R web/posengine ${ROOT_VOLUME_MOUNT_DIR}/apache/htdocs		
	echo "Done deploying static content..."

}

deploy_ear(){

	echo "Deploying ear file..."		
	cp wildfly/IncentiveHubService.ear ${ROOT_VOLUME_MOUNT_DIR}/wildfly/deployments	
	echo "Done deploying ear file..."

}

deploy_app(){
	deploy_static
	deploy_ear
}

#Main logic

case $1 in 
    up)
        echo "Up..."
		
		case $2 in 
			virtualbox)
				echo "virtualbox..."
				DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}

		        set +e
		        # check if host exists
				echo "checking if ${DOCKER_HOST_NAME} exists..."
		        docker-machine inspect ${DOCKER_HOST_NAME} >/dev/null
		        if [[ $? -eq 0 ]]; then
		            echo "Host already exists, exiting."
		            exit 0
		        fi 
		        set -e

				# make new host since one doesn't exit yet
				echo "creating machine ${DOCKER_HOST_NAME} for driver $2..."
				docker-machine create --driver $2 --virtualbox-cpu-count 2 --virtualbox-memory "4096" --virtualbox-disk-size "30000" ${DOCKER_HOST_NAME}
				DOCKER_IP=$(docker-machine ip ${DOCKER_HOST_NAME})
				
				echo "setting default host..."
				set_host_default 				
				#docker-machine active ${DOCKER_HOST_NAME}
				


				
				echo "Access at ${DOCKER_IP}" 
				
				;;		
			
			*)
				print_usage
				exit 1
		esac	



		
        ;;
    down)        
        echo "Down..."

		case $2 in 
			virtualbox)
				echo "virtualbox..."
				DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}
				docker-machine rm -f ${DOCKER_HOST_NAME}
				;;
		
			*)
				print_usage
				exit 1
		esac	

		
        ;;
    deploy-tensorflow)

		echo "Deploying tensorflow..."
		
		case $2 in 
			virtualbox)
				echo "virtualbox..."
				DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}
				DOCKER_IP=$(docker-machine ip ${DOCKER_HOST_NAME})				
				IMAGE_TAG=$3
				
				echo "setting default host..."
				set_host_default 				
				#docker-machine active ${DOCKER_HOST_NAME}
				

				#echo "Building app..."
				#build_app

				echo "Starting app..."
				start_tensorflow_container

				#echo "Deploying app..."
				#deploy_app
				
				echo "Access at ${DOCKER_IP}" 				
				
				;;
		
			
			*)
				print_usage
				exit 1
		esac	
		
        
        ;;
			
	deploy-app)

		echo "Deploying app..."
		
		case $2 in 
			virtualbox)
				echo "virtualbox..."

				deploy_app
				
				;;
		
			amazonec2)
				echo "amazonec2..."
				;;
			*)
				print_usage
				exit 1
		esac	
		
        
        ;;	

	deploy-ear)

		echo "Deploying app..."
		
		case $2 in 
			virtualbox)
				echo "virtualbox..."

				deploy_ear
				
				;;
		
			amazonec2)
				echo "amazonec2..."
				;;
			*)
				print_usage
				exit 1
		esac	
		
        
        ;;	

	deploy-static)

		echo "Deploying app..."
		
		case $2 in 
			virtualbox)
				echo "virtualbox..."

				deploy_static
				
				;;
		
			amazonec2)
				echo "amazonec2..."
				;;
			*)
				print_usage
				exit 1
		esac	
		
        
        ;;	

		
    start-jenkins)
	
		echo "Starting jenkins..."
		
		case $2 in 
			virtualbox)
				echo "virtualbox..."
				DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}
				DOCKER_IP=$(docker-machine ip ${DOCKER_HOST_NAME})				
				IMAGE_TAG=$3
				
				echo "setting default host..."
				set_host_default 				
				#docker-machine active ${DOCKER_HOST_NAME}
				
				echo "Building jenkins container..."
				build_jenkins

				echo "Starting jenkins container..."
				start_jenkins

				echo "Access at ${DOCKER_IP}" 				
				
				;;
		
			*)
				print_usage
				exit 1
		esac	
		
        
    ;;			
    stop-jenkins)
	
		echo "Stopping jenkins..."
		
		case $2 in 
			virtualbox)
				echo "virtualbox..."
				DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}
				DOCKER_IP=$(docker-machine ip ${DOCKER_HOST_NAME})				
				IMAGE_TAG=$3
				
				echo "setting default host..."
				set_host_default 				
				#docker-machine active ${DOCKER_HOST_NAME}
				
				shutdown_jenkins_container				
				
				;;
		
			*)
				print_usage
				exit 1
		esac	
		
        
    ;;			
	
	
	
	test)
		echo "Testing..."
		init_build

		;;
			
    *)
		print_usage
        exit 1
		
esac



