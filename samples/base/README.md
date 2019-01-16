# About
It is a starting point to the development of the proposed training tasks.<br>
Before start, please check the dependencies into `package.json` file and remove the
unnecessaries entries.

# Building an IoT Agent
Build the container:
``` sh
sudo docker build -t dojot-training/iotagent-http .
```
Make sure you allow the agent's port be configurable by the environment variable `SERVER_PORT`.

## Sending a message to the agent
``` sh
DOJOT_HOST="127.0.0.1"
IOTAGENT_PORT=3124
curl -X POST ${DOJOT_HOST}:${IOTAGENT_PORT}/chemsen/readings \
-H 'Content-Type:application/json' \
-d '{ "timestamp": 123456, "data": 646, "device": "dev_test" }'
```

# Building a Flowbroker node
First, build a container with the node
``` sh
sudo docker build -t <flowbroker-node-docker-registry>dojot-training/decode-node<unique-id> .
```

Push it to a docker registry
``` sh
sudo docker push <flowbroker-node-docker-registry>dojot-training/decode-node<unique-id>
```

Now add the node in the Flowbroker:
```sh
DOJOT_HOST="http://localhost:8000"
JWT=$(curl -s -X POST ${DOJOT_HOST}/auth -H 'Content-Type:application/json' -d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
curl -X POST -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node -H "content-type: application/json" -d '{"image": "<flowbroker-node-docker-registry>dojot-training/decode-node<unique-id>", "id":"decode-node"}'
```
Make sure you have the `jq` installed on your system, otherwise set the `JWT` variable manually.

If you want to remove the node, you can do it with the following commands:
```sh
DOJOT_HOST="http://localhost:8000"
JWT=$(curl -s -X POST ${DOJOT_HOST}/auth -H 'Content-Type:application/json' -d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
curl -X DELETE -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node/decode-node
```
