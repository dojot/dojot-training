#!/bin/sh

if [ "$1" = "-h" ] || [ "$1" = "help" ] || [ "$1" = "--help" ] ; then
  echo "usage: $0 <MODE> [<REGISTRY_IP>:<REGISTRY_PORT>]"
  echo "where MODE can be 'mqtt' or 'http'"
  echo "using it without the registry parameter means you are not using a private registry"
  exit 0
fi

MODE=$1
PRIVATE_REGISTRY=$2

if [ "${MODE}" = "mqtt" ] ; then
	cat docker-compose/dojot-base.yml docker-compose/dojot-mqtt.yml docker-compose/network.yml > docker-compose/docker-compose.yml
elif [ "${MODE}" = "http" ] ; then
	cat docker-compose/dojot-base.yml docker-compose/dojot-http.yml docker-compose/network.yml > docker-compose/docker-compose.yml
else
  echo "invalid mode: " ${MODE}
  exit 1
fi

if [ "${PRIVATE_REGISTRY}" != "" ] ; then
 PRIVATE_REGISTRY=${PRIVATE_REGISTRY}"\/"
fi

LOOKUP_DIRS="samples/ tasks/ docker-compose/"
LOOKUP_TAG="<private-docker-registry>"
RANDOM_TAG="<unique-id>"
UNIQUE_ID=$(shuf -i 0-9999 -n 1)

grep -ril "${LOOKUP_TAG}" ${LOOKUP_DIRS} | xargs sed -i "s/\(.*\)${LOOKUP_TAG}\(.*\)/\1${PRIVATE_REGISTRY}\2/"
grep -ril "${RANDOM_TAG}" ${LOOKUP_DIRS} | xargs sed -i "s/\(.*\)${RANDOM_TAG}\(.*\)/\1${UNIQUE_ID}\2/"
