#!/bin/bash

USAGE="$0 -U <dojot-url> -u <dojot-user> -p <dojot-password>"

while getopts "U:u:p:" options; do
  case $options in
    U ) DOJOT_URL=$OPTARG;;
    u ) DOJOT_USERNAME=$OPTARG;;
    p ) DOJOT_PASSWD=$OPTARG;;
    \? ) echo ${USAGE}
         exit 1;;
    * ) echo ${USAGE}
          exit 1;;
  esac
done

if [ -z ${DOJOT_URL} ] || [ -z ${DOJOT_USERNAME} ] || [ -z ${DOJOT_PASSWD} ]
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

# Create Template
echo 'Creating template ...'
TEMPLATE_ID=$(curl --silent -X POST ${DOJOT_URL}/template \
-H 'Content-Type:application/json' \
-H "Authorization: Bearer ${JWT}" \
-d  '{
       "label": "ColdChainTemplate", 
       "attrs": [
                  {
                    "label": "protocol", 
                    "type": "meta", 
                    "value_type": "string", 
                    "static_value": "mqtt"
                  },
                  {
                    "label": "truckID", 
                    "type": "static", 
                    "value_type": "string", 
                    "static_value": "undefined"
                  },
                  {
                    "label": "temperature", 
                    "type": "dynamic",  
                    "value_type": "float"
                  },
                  {
                    "label": "location", 
                    "type": "dynamic",  
                    "value_type": "geo:point"
                  },
                  {
                    "label": "message",
                    "type": "actuator", 
                    "value_type": "string"
                  }
               ]
    }' | jq '.template.id')
echo "... Created template ${TEMPLATE_ID}."

# Get id of the attribute truckID in the corresponding template
echo 'Getting id of attribute truckID ...'
ATTR_ID=$(curl --silent -X GET ${DOJOT_URL}/template/${TEMPLATE_ID} \
-H 'Content-Type:application/json' \
-H "Authorization: Bearer ${JWT}" | jq '.attrs[] | select(.label == "truckID") | .id')
echo "... Got attribute id ${ATTR_ID}"

# Create Devices
echo 'Creating 3 devices ...'
for n in 1 2 3; do
DEVICE_ID=$(curl --silent -X POST ${DOJOT_URL}/device \
  -H 'Content-Type:application/json' \
  -H "Authorization: Bearer ${JWT}" \
  -d  "{
          \"templates\": [\"${TEMPLATE_ID}\"],
          \"attrs\": [{
                        \"template_id\" : \"${TEMPLATE_ID}\",
                        \"id\": ${ATTR_ID},	
                        \"label\": \"truckID\",
                        \"type\": \"static\",
                        \"value_type\": \"string\",
                        \"static_value\" : \"${n}\"
                      }],
          \"label\": \"Truck-${n}\"
      }" | jq '.devices[0].id')
  echo "... Created device Truck-${n} (${DEVICE_ID})."
done