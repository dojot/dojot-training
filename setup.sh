#!/bin/bash

function print_help() {
  echo "usage: $0 -m <MODE> [OPTIONS]"
  echo ""
  echo "  the mandatory parameters are:"
  echo "    -m | --mode [mqtt | http] : enables the chosen iot-agent. This must be chosen according to the hands-on tasks."
  echo "  where OPTIONS could be:"
  echo "    -f | --flowbroker-node-registry <REGISTRY_IP>:<REGISTRY_PORT> : informs which is the registry used by the flowbroker. If not set, a localhost registry will be used."
  echo "    -s | --shared-flowbroker-node-registry : Must be set if the docker registry used by the flowbroker is shared by multiple users."
  echo "    -i | --image-docker-registry <REGISTRY_IP>:<REGISTRY_PORT> : Docker registry with dojot's images. Defaults is to use docker hub."
}


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -m|--mode)
    MODE="$2"
    shift # past argument
    shift # past value
    ;;
    -i|--image-docker-registry)
    IMAGE_DOCKER_REGISTRY="$2"
    shift # past argument
    shift # past value
    ;;
    -f|--flowbroker-node-registry)
    FLOWBROKER_NODE_REGISTRY="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--shared-flowbroker-node-registry)
    SHARED_FLOWBROKER_NODE_REGISTRY=true
    shift # past argument
    ;;
    -h|--help)
    PRINT_HELP=true
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters


# help requested
if [ ${PRINT_HELP} ] ; then
  print_help
  exit 0
fi


# check mandatory parameters
if [ -z "${MODE}" ]; then
  echo "missing mandatory parameter"
  print_help
  exit 1
fi

## TODO: It would be nice to have some kind of input files
## with permanent tags, and generate the output files from them.
## In the current implementation after run the script for the first time, 
## you cannot set the repositories anymore. 

# build the docker-compose file
DOCKER_COMPOSE_FILE=docker-compose/docker-compose.yml
cat docker-compose/dojot-base.yml > ${DOCKER_COMPOSE_FILE}
if [ "${MODE}" = "mqtt" ]; then
  cat docker-compose/dojot-mqtt.yml >> ${DOCKER_COMPOSE_FILE}
elif [ "${MODE}" = "http" ] ; then
  cat docker-compose/dojot-http.yml >> ${DOCKER_COMPOSE_FILE}
else
  echo "invalid mode: " ${MODE}
  rm ${DOCKER_COMPOSE_FILE}
  exit 1
fi
if [ -z "${FLOWBROKER_NODE_REGISTRY}" ]; then
  cat docker-compose/dojot-registry.yml >> ${DOCKER_COMPOSE_FILE}
  FLOWBROKER_NODE_REGISTRY="localhost:5009"
fi
cat docker-compose/network.yml >> ${DOCKER_COMPOSE_FILE}

LOOKUP_DIRS="samples/ tasks/ docker-compose/"

# replace the image docker registry
if [ -n "${IMAGE_DOCKER_REGISTRY}" ] ; then
  IMAGE_DOCKER_REGISTRY=${IMAGE_DOCKER_REGISTRY}"\/"
fi
LOOKUP_TAG="<image-docker-registry>"
grep -ril "${LOOKUP_TAG}" ${LOOKUP_DIRS} | xargs -r sed -i "s/\(.*\)${LOOKUP_TAG}\(.*\)/\1${IMAGE_DOCKER_REGISTRY}\2/"


# replace the flowbroker node docker registry
if [ -n "${FLOWBROKER_NODE_REGISTRY}" ] ; then
  FLOWBROKER_NODE_REGISTRY=${FLOWBROKER_NODE_REGISTRY}"\/"
fi
LOOKUP_TAG="<flowbroker-node-docker-registry>"
grep -ril "${LOOKUP_TAG}" ${LOOKUP_DIRS} | xargs -r sed -i "s/\(.*\)${LOOKUP_TAG}\(.*\)/\1${FLOWBROKER_NODE_REGISTRY}\2/"


# deal with shared flowbroker node docker registry
RANDOM_TAG="<unique-id>"
if [ ${SHARED_FLOWBROKER_NODE_REGISTRY} ]; then
  UNIQUE_ID=$(shuf -i 0-9999 -n 1)
fi
grep -ril "${RANDOM_TAG}" ${LOOKUP_DIRS} | xargs -r sed -i "s/\(.*\)${RANDOM_TAG}\(.*\)/\1${UNIQUE_ID}\2/"
