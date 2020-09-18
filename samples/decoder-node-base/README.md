# About

In decoder node base, you will find:

``` sh
.
├── Dockerfile              - file to build the docker container
├── package.json            - javascript dependencies
├── README.md               - README file
└── src
    ├── decoder-node.html   - the node html
    ├── index.js            - the decoder logic
    └── locales             - used by internationalization
```


# How to build and add it to Dojot

Build the docker image:
```sh
docker build -t <your dockerHub username>/decoder-node:<unique-id> .
```
Publish it on your DockerHub:
```sh
docker push <your dockerHub username>/decoder-node:<unique-id>
```

Acquire a Dojot's token:
```sh
JWT=$(curl -s -X POST http://localhost:8000/auth \
-H 'Content-Type:application/json' \
-d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
```

Note: the previous command requires the `jq`and `curl` command, you can install it on ubuntu
with the following command:
```
sudo apt-get install jq
sudo apt-get install curl
```

Add the node to Dojot.
```sh
curl -H "Authorization: Bearer ${JWT}" http://localhost:8000/flows/v1/node -H 'content-type: application/json' -d '{"image": "<your dockerHub username>/decoder-node:<unique-id>", "id":"decoder-node"}'
```

To remove the node in Dojot.
```sh
curl -X DELETE -H "Authorization: Bearer ${JWT}" http://localhost:8000/flows/v1/node/decoder-node
```
##### Tip: To view the logs from your remote node run:

```sh
sudo docker logs -f -t $(sudo docker ps -aqf "ancestor=<your dockerHub username>/decoder-node:<unique-id>")
```

Now the decoder node will be available on `decoders` category into the FlowBroker Dojot's interface.

Note: the DockerHub use is optional, you can use a private docker registry instead.

Note2: All commands considers that you are running Dojot locally, if it is not
the case, please, adapt them to refect your scenario.


ATTENTION: The `id` to add the node via API (when request `/flows/v1/node`) must be the same as `name` and `id` defined in `getMetadata` in the class that extends `dojot.DataHandlerBase`. And within the html called in the `getNodeRepresentationPath` method also in the class that extends `dojot.DataHandlerBase` the references `data-template-name=`, `data-help-name=`, `registerType(..` ,  and `RED._("decoder-node:...` must have this same id/name.