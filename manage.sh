#!/bin/bash

set -e

echo "=>Sourcing..."
source setenv.sourceme

print_usage(){
	echo "Usage: manage.sh [spark_sci deploy | spark_sci undeploy | down]"
}

init(){
	echo "=>Init"
	DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}			
	set +e			
	HOST_EXIST=false
	docker-machine inspect ${DOCKER_HOST_NAME} >/dev/null		
	if [[ $? -eq 0 ]]; then					
		HOST_EXIST=true			
	fi 
	set -e			
	if [[ $HOST_EXIST == false ]]; then 
		echo "=>Creating machine ${DOCKER_HOST_NAME} for driver ${DOCKER_VBOX_DRIVER}..."
		docker-machine create --driver ${DOCKER_VBOX_DRIVER} --virtualbox-cpu-count 2 --virtualbox-memory "6000" --virtualbox-disk-size "30000" ${DOCKER_HOST_NAME}	
	fi	

	echo "=>Setting docker ip..."
	DOCKER_IP=$(docker-machine ip ${DOCKER_HOST_NAME})			
	
	echo "=>Fixing map count..."
	docker-machine ssh ${DOCKER_HOST_NAME} "sudo sysctl -w vm.max_map_count=262144"
		
	echo "=>Setting default machine"
	eval "$(docker-machine env ${DOCKER_HOST_NAME})"
}


#Main logic

start=`date +%s`
init


case $1 in 

    spark_sci)
        echo "=>Spark sci..."

		case $2 in 

			deploy)
				echo "=>deploy..."
				#docker-compose --file docker-compose-spark-sci.yml up --build &	
				docker-compose --file docker-compose-spark-sci.yml up --build --force-recreate &
				;;

			undeploy)
				echo "=>undeploy..."
				docker-compose --file docker-compose-spark-sci.yml down
				;;
				
			*)
				print_usage
				exit 1
				
		esac

		
        ;;

    down)        
        echo "=>Down..."
		DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}		
		set +e
		docker-machine rm -f ${DOCKER_HOST_NAME}		
		rm -rf ~/.docker/machine/machines/${DOCKER_HOST_NAME} -- >/dev/null 2>&1 || true						
		set -e		
		
        ;;		
    *)
		print_usage
        exit 1
		
esac

end=`date +%s`
runtime=$((end-start))
echo "Script running time: ${runtime} seconds"























#!/bin/bash
#set -e
#
#echo "=>Sourcing..."
#source setenv.sourceme
#source spark_sci/manage-spark-sci.sh
#
#print_usage(){
#	echo "Usage: manage.sh [deploy | down ]"
#}
#
#init(){
#	echo "==>Init"
#	DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}
#}
#
#
#build_images(){			
#	build_spark_sci_image
#}
#
#start_containers(){		
#	start_spark_sci_container
#}
#
#
##Main logic
#
#start=`date +%s`
#init
#
#case $1 in 
#
#    deploy)
#        echo "=>Deploying..."
#
#		DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}
#
#		set +e		
#		echo "=>Checking if ${DOCKER_HOST_NAME} exists..."
#		HOST_EXIST=false
#		docker-machine inspect ${DOCKER_HOST_NAME} >/dev/null		
#		if [[ $? -eq 0 ]]; then			
#			echo "setting to HOST_EXIST to true"
#			HOST_EXIST=true			
#		fi 
#		set -e		
#		echo "=>Host ${DOCKER_HOST_NAME} exists? $HOST_EXIST"
#
#		if [[ $HOST_EXIST == false ]]; then 
#			echo "=>Creating machine ${DOCKER_HOST_NAME} for driver virtualbox..."
#			docker-machine create --driver ${DOCKER_VBOX_DRIVER} --virtualbox-cpu-count 2 --virtualbox-memory "6000" --virtualbox-disk-size "30000" ${DOCKER_HOST_NAME}			
#		fi
#		
#		
#		DOCKER_IP=$(docker-machine ip ${DOCKER_HOST_NAME})			
#		docker-machine ssh ${DOCKER_HOST_NAME} "sudo sysctl -w vm.max_map_count=262144"
#		
#		echo "=>Setting default machine"
#		eval "$(docker-machine env ${DOCKER_HOST_NAME})"
#		
#		echo "=>Building images..."
#		build_images 
#
#		echo "=>Starting containers..."
#		start_containers
#		
#		echo "=>Access at ${DOCKER_IP}" 
#		
#        ;;
#		
#    down)        
#        echo "=>Down..."
#		DOCKER_HOST_NAME=${APP_NAME}-${DOCKER_VBOX_DRIVER}		
#		set +e
#		docker-machine rm -f ${DOCKER_HOST_NAME}		
#		rm -rf ~/.docker/machine/machines/${DOCKER_HOST_NAME} -- >/dev/null 2>&1 || true						
#		set -e		
#		
#        ;;
#	
#    *)
#		print_usage
#        exit 1
#		
#esac
#
#end=`date +%s`
#runtime=$((end-start))
#echo "Script running time: ${runtime} seconds"
