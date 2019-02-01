#!/bin/bash

USAGE="$0 -U <dojot-url> -u <dojot-user> -p <dojot-password> -d <device-id> -m <message>"

while getopts "U:u:p:d:m:" options; do
  case $options in
    U ) DOJOT_URL=$OPTARG;;
    u ) DOJOT_USERNAME=$OPTARG;;
    p ) DOJOT_PASSWD=$OPTARG;;
    d ) DEVICE_ID=$OPTARG;;
    m ) MESSAGE=$OPTARG;;
    \? ) echo ${USAGE}
         exit 1;;
    * ) echo ${USAGE}
          exit 1;;
  esac
done

if [ -z ${DOJOT_URL} ] || [ -z ${DOJOT_USERNAME} ] || 
   [ -z ${DOJOT_PASSWD} ] || [ -z ${DEVICE_ID} ] || 
   [ -z "${MESSAGE}" ]
then
    echo ${USAGE}
    exit 1
fi

# JWT Token
echo 'Getting jwt token ...'
JWT=$(curl --silent -X POST ${DOJOT_URL}/auth \
-H "Content-Type:application/json" \
-d "{\"username\": \"${DOJOT_USERNAME}\", \"passwd\" : \"${DOJOT_PASSWD}\"}" | jq '.jwt' | tr -d '"')
echo "... Got jwt token ${JWT}."

# Send message from dojot to device
echo "Sending message ${MESSAGE} ..."
RESPONSE=$(curl -w "\n%{http_code}" --silent -X PUT ${DOJOT_URL}/device/${DEVICE_ID}/actuate \
-H "Content-Type:application/json" \
-H "Authorization: Bearer ${JWT}" \
-d "{
      \"attrs\": {
                    \"message\": \"${MESSAGE}\"
                  }
    }")
RESPONSE=(${RESPONSE[@]}) # convert to array
HTTP_STATUS=${RESPONSE[-1]} # get last element (last line)
BODY=${RESPONSE[@]::${#RESPONSE[@]}-1} # get all elements except last

 if [ "${HTTP_STATUS}" == "200" ]
then
  echo "... Succeeded to send message."
  echo "${BODY}"
else
  echo '... Failed to send message.'
  echo "${BODY}"
fi