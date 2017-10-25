
#Create virtual machine
docker-machine create --driver virtualbox --virtualbox-cpu-count 2 --virtualbox-memory "4096" --virtualbox-disk-size "50000" default

#build spark-notebook image
docker build --tag ansosoft/spark-notebook:latest .

#set docker-machine with docker
eval "$(docker-machine env default)"


#run spark-notebook container 
#mac
docker run -d -p 8888:8888 -p 54321:54321 -v /Users/admin/ansosoft/volumes/notebook:/home/jovyan/work ansosoft/spark-notebook:latest 

#win
docker run -d -p 8888:8888 -p 54321:54321 -v //c/Users/asochal/volumes/notebook:/home/jovyan/work ansosoft/spark-notebook:latest 

winpty docker exec -it --user root 3491fc62d355 bash
//this is a work around to make import cv2 not throw errors
export PYTHONPATH=/usr/local/lib/python3.5/site-packages:$PYTHONPATH


#push new image to dockerhub
winpty docker login
docker push ansosoft/spark-notebook:latest


#remove all images
docker rmi -f $(docker images -q)

#remove all containers 
docker rm -f $(docker ps -aq)


		
