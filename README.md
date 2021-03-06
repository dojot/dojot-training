# dojot-training

## About
This repository is the workspace for the dojot's training.

Here, you'll find instructions and recipes to support you.

## Table of Contents

* [dojot-training](#dojot-training)
  * [Prerequisites](#prerequisites)
  * [Setting up your Ubuntu machine](#setting-up-your-ubuntu-machine)
      * [Docker](#docker)
      * [Docker Compose](#docker-compose)
      * [Git](#git)
      * [HTTP Client](#http-client)
      * [JQ](#json-processor-command-line)
      * [MQTT Client](#mqtt-client)
      * [Javascript Editor](#javascript-editor)
  * [<strong>Hands-on</strong>](#hands-on)
  * [Use Cases](#use-cases)
      * [Cold-chain monitoring](#cold-chain-monitoring)
      * [Water quality monitoring](#water-quality-monitoring)
  * [Tasks](#tasks)
      * [Task 1: Configure and simulate the cold-chain monitoring use case](#task-1-configure-and-simulate-the-cold-chain-monitoring-use-case)
      * [Task 2: Develop an iot-agent for the water quality monitoring use case](#task-2-develop-an-iot-agent-for-the-water-quality-monitoring-use-case)
        * [Step 1: Start a dummy iotagent-http](#step-1-start-a-dummy-iotagent-http)
        * [Step 2: Implement your iotagent-http for the water quality monitoring use case](#step-2-implement-your-iotagent-http-for-the-water-quality-monitoring-use-case)
        * [Step 3: Test your iotagent-http](#step-3-test-your-iotagent-http)
      * [Task 3: Develop a function node for the water quality monitoring use case](#task-3-develop-a-function-node-for-the-water-quality-monitoring-use-case)
        * [Step 1: Load a stub of the decoder node into flowbroker](#step-1-load-a-stub-of-the-decoder-node-into-flowbroker)
        * [Step 2: Implement the decoder logic](#step-2-implement-the-decoder-logic)
        * [Step 3: Test your decoder node](#step-3-test-your-decoder-node)

## Prerequisites

To do the tasks, you will need:

- A machine with Ubuntu 18.04 or 20.04 with at least 4GB RAM

- User with sudo permissions

- Connection with the Docker Hub or any other Docker Registry that contains dojot's docker images.

- Docker > 17.12

- Docker Compose > 1.18

- Git

- HTTP Client

- JQ

- MQTT Client

- JavaScript Editor

## Setting up your Ubuntu machine

### Docker
Instructions to install docker on Ubuntu can be found at [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

Checking docker version:

``` sh
sudo docker -v
```

### Docker Compose

Instructions to install docker compose on Ubuntu can be found at [Docker Compose Install](https://docs.docker.com/compose/install/).

Checking docker-compose version:

``` sh
sudo docker-compose -v
```

### Git

To install git:

``` sh
sudo apt-get install git
```

### HTTP Client

Our suggestion is to use curl, but if you are familiar with other tools like postman, feel free to use them. To install curl:

``` sh
sudo apt-get install curl
```

If you use Postman, we have the collection and the environment used in this training available in the [`postman`](./postman) directory.

### JSON processor (command-line)

Our suggestion is to use JQ with Curl. To install JQ:

``` sh
sudo apt-get install jq
```

### MQTT Client

Our suggestion is to use mosquitto clients, but if you are familiar with other clients, feel free to use them. To install mosquitto clients:

``` sh
sudo apt-get install mosquitto-clients
```

NOTE: Some Linux distributions, Debian-based Linux distributions in particular, have two packages for mosquitto - one containing tools to access it (i.e. mosquitto_pub and mosquitto_sub for publishing messages and subscribing to topics) and another one containing the MQTT broker too. In this training, only the tools from package mosquitto-clients on Debian-based Linux distributions are going to be used. Please check if MQTT broker is not running before starting dojot (by running commands like ps aux | grep mosquitto) to avoid port conflicts.

### Javascript Editor

Some of the hands-on will require to develop Javascript code. Our suggestion is to use Visual Studio Code, but feel free to choose a code editor of your preference.

Instructions to install vs code can be found at [VSCode Installation](https://code.visualstudio.com/docs/setup/linux). Basically, you need to run:

``` sh
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

sudo apt-get install apt-transport-https
sudo apt-get update
sudo apt-get install code # or code-insiders
```

## **Hands-on**

## Use Cases

### Cold-chain monitoring

A company of the cold-chain sector wants to carry out a proof of concept with the dojot platform.
The company wants to monitor their refrigerated trucks (location and temperature) and records when:

- The temperature reaches values outside an acceptable range.
- The truck leaves the planned route.

It also wants to send messages from its operational center to the drivers. These notification messages are shown on a display in the trucks.

Messages from device to dojot and vice-versa are sent through MQTT protocol.

### Water quality monitoring

A company produces an IoT device with pollutant and oxygenation level detectors. It will install several of them along a river near a factory to assess the water treatment. Due to the simplicity of the device, it sends the data corresponding to the two measurements (pollutant and oxygenation) in a 16-bit message. Each value is encoded in 8 bits. The data is sent hourly to a gateway that relays it to dojot via HTTP protocol.

A sample message is given bellow:

```
POST /chemsen/readings
{
  "timestamp": 1543449992,           - unix timestamp: 11/29/2018 - 12:06am
  "data": 656,                       - pollutant = 00000010b = 2 | oxygenation = 10010000b = 144
  "device": "PINHR_003"              - unique device label identifier
}
```

Before starting, take a look at:

- https://dojotdocs.readthedocs.io/en/v0.4.3/using-web-interface.html

- https://dojotdocs.readthedocs.io/en/v0.4.3/using-api-interface.html

- https://dojotdocs.readthedocs.io/en/v0.4.3/flow.html

- https://dojotdocs.readthedocs.io/en/v0.4.3/iotagent-architecture.html

- https://dojotdocs.readthedocs.io/en/v0.4.3/components-and-apis.html


## Tasks

### Task 1: Configure and simulate the cold-chain monitoring use case

First of all, you need clone the docker-compose repository, see more in https://dojotdocs.readthedocs.io/en/v0.4.3/installation-guide.html#installation:

``` sh
git clone https://github.com/dojot/docker-compose
cd docker-compose
sudo docker-compose up -d
cd -
```

Wait for some seconds and run:

``` sh
sudo docker ps -a
```

The goal of doing this task is to learn how to use dojot's gui and api.

To accomplish this task, do the following sub-tasks:

1. Create a template for the truck's sensors (gps, thermometer) and actuator (display). Try out both gui and api.

2. Instantiate three devices. Try out both gui and api.

3. Generate MQTT data for the devices.

4. Configure processing flows to register when the temperatures of the containers are out of range.

5. Configure processing flows to register when the trucks leaves the planned routes.

6. Send notifications from dojot to the devices.

7. [Extra] Change the template to include a luminosity sensor.

8. [Extra] Configure processing flows to detect, based on the luminosity sensors, if the container's doors are opened on unexpected areas.

9. [Extra] Retrieve the history of the devices' data using the api.

10. [Extra] Retrieve the devices' data in real time (https://dojot.github.io/data-broker/apiary_v0.4.3.html#websockets)


TIP: If you want to stop dojot's microservices, run:

``` sh
cd docker-compose
sudo docker-compose down
cd -
```

Note: But if you stop dojot, you will lose all settings for template, device, flows and history data. In order not to lose the settings of template, device, flows, see more about import and export at: https://dojotdocs.readthedocs.io/en/v0.4.3/using-web-interface.html#import-and-export



### Task 2: Develop an iot-agent for the water quality monitoring use case

First of all, you need clone the docker-compose repository, see more in https://dojotdocs.readthedocs.io/en/v0.4.3/installation-guide.html#installation:

``` sh
git clone https://github.com/dojot/docker-compose
cd docker-compose
sudo docker-compose up -d
cd -
```
Wait for some seconds and run:

``` sh
sudo docker ps -a
```


The goal of doing this task is to learn how to develop an iot-agent microservice. This is REQUIRED to integrate a device not supported by dojot.

Take a look at https://github.com/dojot/iotagent-nodejs

If you dont't know what to do, don't panic; just follow the steps listed bellow.

#### Step 1: Start a dummy iotagent-http

There is a dummy iotagent-http at samples/iotagent-base. There, you will find:

``` sh
.
├── Dockerfile        - file to build the docker container
├── package.json      - javascript dependencies
├── README.md         - README file
└── src
    └── index.js      - the microservice code

```

First, let's build the docker image for this microservice:

``` sh
cd dojot-training/samples/iotagent-base
sudo docker build -t iotagent-http .
cd -
```

Then you need to add the service `iotagent-http:`, as below, in the file docker-compose.yml inside `services:` and start it:

```
  iotagent-http:
      image: iotagent-http
      depends_on:
        - kafka
        - data-broker
        - auth
      ports:
        - 3124:3124
      restart: always
      environment:
        SERVER_PORT: 3124
      logging:
        driver: json-file
        options:
          max-size: 100m
```

*NOTE: Here we are exposing port 3124 to be accessed without going through the api gateway, kong, that is, without authorization, the correct thing is to create a route in kong and remove `ports: - 3124: 3124` from the code above. About routes in kong, see more at [auth-api-gateway-kong](https://dojotdocs.readthedocs.io/en/v0.4.3/internal-communication.html#auth-api-gateway-kong). And in addition a Tip: You can simply add the route `http://iotagent-http:3124`in the `kong.config.sh` following the pattern of what already exists, this file is inside the dojot `docker-compose` repository ( don't forget to call the `authConfig` function for the route to be authenticated and [create a permission at `Auth`](https://dojot.github.io/auth/apiary_v0.4.3.html#crud-permissions-and-group-permissions-creation-and-search-post)). Besides that for changes in `kong.config.sh` to be applied you need to restart the service with `sudo docker-compose restart kong-config`. And to apply the 3124 port exposure removal it is necessary to kill and up `iotagent-http`, the commands are `sudo docker-compose kill iotagent-http` and `sudo docker-compose up -d  iotagent-http`*


Now let's open the file `docker-compose.yml` and add the service `iotagent-http:` from the code above:

``` sh
cd docker-compose
code docker-compose.yml # vi docker-compose.yml, pico docker-compose.yml or another editor
sudo docker-compose up -d iotagent-http
cd -
```

Wait some seconds and check its log:

``` sh
cd docker-compose
sudo docker-compose logs -t -f iotagent-http
cd -
```

You should see some messages that the microservice is running.

To send a HTTP message to this agent, run:

``` sh
DOJOT_HOST="127.0.0.1"
IOTAGENT_PORT=3124
curl -X POST ${DOJOT_HOST}:${IOTAGENT_PORT}/chemsen/readings \
-H 'Content-Type:application/json' \
-d '{ "timestamp": 1543449992, "data": 646, "device": "PINHR_003" }'
```

if you check the logs again, you should see that the message has been received.

#### Step 2: Implement your iotagent-http for the water quality monitoring use case

Now, you need to customize the dummy iotagent-http for handling the use case.
Openning the file samples/iotagent-http/src/index.js, you  will see a list of TODOs.
You just need to implement them.

Once you've finished, you need to rebuild and restart the service:

``` sh
cd dojot-training/samples/iotagent-base
sudo docker build -t iotagent-http .
cd -
cd docker-compose
sudo docker-compose up -d iotagent-http
cd -
```

Check the logs to see if it's running.

#### Step 3: Test your iotagent-http

Create the template and devices for the water quality monitoring use case. Then, generate some
HTTP messages and validate if they are associated with the corresponding devices.

### Task 3: Develop a function node for the water quality monitoring use case

The goal here is to learn how to develop function nodes to extend the flowbroker microservice.

You can find instructions how to do this from scratch at https://github.com/dojot/flowbroker/tree/v0.4.3/lib. So, go there and take a look.

Try to develop the decoder function by yourself. If you get stuck, follow the steps bellow.

#### Step 1: Load a stub of the decoder node into flowbroker

There is a stub for this microservice at samples/decoder-node-base. There, you will find:

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

Before login with your Docker ID to push images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.

``` sh
sudo docker login
```

First, build the container:

``` sh
cd dojot-training/samples/decoder-node-base
sudo docker build -t  <your dockerHub username>/decoder-node:<unique-id> .
cd -
```

Then, push it to the docker hub:

``` sh
sudo docker push  <your dockerHub username>/decoder-node:<unique-id>
```

Now, load the node into the flowbroker:

ATTENTION: The `id` to add the node via API (when request `/flows/v1/node`) must be the same as `name` and `id` defined in `getMetadata` in the class that extends `dojot.DataHandlerBase`. And within the html called in the `getNodeRepresentationPath` method also in the class that extends `dojot.DataHandlerBase` the references inside the html `data-template-name=`, `data-help-name=`, `registerType(..` ,  and `RED._("...` must have this same `id`/`name`.

```sh
DOJOT_HOST="http://localhost:8000"
JWT=$(curl -s -X POST ${DOJOT_HOST}/auth -H 'Content-Type:application/json' -d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
curl -X POST -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node -H "content-type: application/json" -d '{"image": "<your dockerHub username>/decoder-node:<unique-id>", "id":"decoder-node"}'
```
Make sure you have the `jq` and `curl`  installed on your system, otherwise set the `JWT` variable manually. You can install `jq` and `curl` on ubuntu with the following command:
```
sudo apt-get install jq
sudo apt-get install curl
```

If you want to remove the node, run:

```sh
DOJOT_HOST="http://localhost:8000"
JWT=$(curl -s -X POST ${DOJOT_HOST}/auth -H 'Content-Type:application/json' -d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
curl -X DELETE -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node/decoder-node
```
Now, you should be able to access the decoder node at the dojot's gui.

#### Step 2: Implement the decoder logic

Openning the file samples/decoder-node-base/src/index.js, you  will see a TODO.
You just need to implement it. See about bitwise in https://www.w3schools.com/js/js_bitwise.asp .

Once you've finished, you need to rebuild the container and push it to the registry.
So, run:

NOTE: Always change the `<unique-id>` of the docker image, to force the update and see your changes reflected.

``` sh
cd dojot-training/samples/decoder-node-base
sudo docker build -t <your dockerHub username>/decoder-node:<unique-id> .
sudo docker push <your dockerHub username>/decoder-node:<unique-id>
cd -
```

Now, reloads the node into the flowbroker:

``` sh
DOJOT_HOST="http://localhost:8000"
JWT=$(curl -s -X POST ${DOJOT_HOST}/auth -H 'Content-Type:application/json' -d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
curl -X DELETE -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node/decoder-node
curl -X POST -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node -H "content-type: application/json" -d '{"image": "<your dockerHub username>/decoder-node:<unique-id>", "id":"decoder-node"}'
```

##### Tip: To view the logs from your remote node run:

```sh
sudo docker logs -f -t $(sudo docker ps -aqf "ancestor=<your dockerHub username>/decoder-node:<unique-id>")
```

##### Tip: To kill the remote node's container if it becomes active even after the dojot stops:

To check if containers are still active:

``` sh
sudo docker ps -a
```

Killing the  remote node's container:

**Avoid using this, use this only if really necessary.**

```sh
sudo docker rm -f $(sudo docker ps -aqf "ancestor=<your dockerHub username>/decoder-node:<unique-id>")
```

#### Step 3: Test your decoder node

Create virtual devices to receive the decoded values and a processing flow for executing the decoder. Then, generate some HTTP or MQTT messages for the devices and look at the virtual ones to see if the values appeared decoded.
