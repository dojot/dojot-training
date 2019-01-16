#!/bin/bash

function print_help() {
  echo "usage: $0 -m <MODE> -f <REGISTRY_IP>:<REGISTRY_PORT> [OPTIONS]"
  echo ""
  echo "  the mandatory parameters are:"
  echo "    -m | --mode [mqtt | http] : select the kind of device will be used"
  echo "    -f | --flowbroker-node-registry <REGISTRY_IP>:<REGISTRY_PORT> : inform which is the registry used by the flowbroker"
  echo "  where OPTIONS could be:"
  echo "    -s | --shared-flowbroker-node-registry : if the docker register used by the flowbroker is shared"
  echo "    -i | --image-docker-registry <REGISTRY_IP>:<REGISTRY_PORT> : if there is a docker register with the dojot's images"
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
if [ -z "${MODE}" ] || [ -z "${FLOWBROKER_NODE_REGISTRY}" ] ; then
  echo "missing mandatory parameter"
  print_help
  exit 1
fi


# build the docker-compose file
if [ "${MODE}" = "mqtt" ] ; then
	cat docker-compose/dojot-base.yml docker-compose/dojot-mqtt.yml docker-compose/network.yml > docker-compose/docker-compose.yml
elif [ "${MODE}" = "http" ] ; then
	cat docker-compose/dojot-base.yml docker-compose/dojot-http.yml docker-compose/network.yml > docker-compose/docker-compose.yml
else
  echo "invalid mode: " ${MODE}
  exit 1
fi


LOOKUP_DIRS="samples/ tasks/ docker-compose/"

# replace the image docker registry
if [ -n "${IMAGE_DOCKER_REGISTRY}" ] ; then
  IMAGE_DOCKER_REGISTRY=${IMAGE_DOCKER_REGISTRY}"\/"
fi
LOOKUP_TAG="<image-docker-registry>"
grep -ril "${LOOKUP_TAG}" ${LOOKUP_DIRS} | xargs sed -i "s/\(.*\)${LOOKUP_TAG}\(.*\)/\1${IMAGE_DOCKER_REGISTRY}\2/"

# replace the flowbroker node docker registry
if [ -n "${FLOWBROKER_NODE_REGISTRY}" ] ; then
  FLOWBROKER_NODE_REGISTRY=${FLOWBROKER_NODE_REGISTRY}"\/"
fi
LOOKUP_TAG="<flowbroker-node-docker-registry>"
grep -ril "${LOOKUP_TAG}" ${LOOKUP_DIRS} | xargs sed -i "s/\(.*\)${LOOKUP_TAG}\(.*\)/\1${FLOWBROKER_NODE_REGISTRY}\2/"


# deal with shared flowbroker node docker registry
RANDOM_TAG="<unique-id>"
if [ ${SHARED_FLOWBROKER_NODE_REGISTRY} ]; then
  UNIQUE_ID=$(shuf -i 0-9999 -n 1)
fi
grep -ril "${RANDOM_TAG}" ${LOOKUP_DIRS} | xargs sed -i "s/\(.*\)${RANDOM_TAG}\(.*\)/\1${UNIQUE_ID}\2/"
