# About
This repository is the workspace for the dojot's training.

Here, you'll find instructions and recipes to support you.

> This documentation contains some tags that is replaced when you run the setup.sh to set your workspace. So, after running this script, don't forget to reload the documentation. 

# Prerequisites

To do the tasks, you will need:

- A machine with Ubuntu 18.04 with at least 4GB RAM

- User with sudo permissions

- Connection with the Docker Hub or any other Docker Registry that contains dojot's docker images.

- Docker > 17.12

- Docker Compose > 1.18

- Git

- JQ

- MQTT Client

- HTTP Client

- JavaScript Editor

# Setting up your Ubuntu machine

## Docker
Instructions to install docker on Ubuntu can be found at https://docs.docker.com/install/linux/docker-ce/ubuntu/. Basically, you need to run:

``` sh
$​​ sudo apt-get remove docker docker-engine docker.io
$ ​sudo apt-get update
$​​ sudo apt-get install \
apt-transport-https \
ca-certificates \
curl \
software-properties-common
$​​ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$​​ sudo apt-key fingerprint 0EBFCD88
$​​ sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
$​​ sudo apt-get update
$​​ sudo apt-get install docker-ce
```

### Allowing an insecure registry

This step is only required for a private docker registry without public certificates.
Ask your tutor if you really need to run the following steps.

1. Create or modify /etc/docker/daemon.json
``` sh
{ 
  "insecure-registries": [ "<private-docker-registry-ip>:<private-docker-registry-port>" ]
}
```

2. Restart docker daemon
``` sh
sudo service docker restart
```

## Docker Compose
Instructions to install docker compose on Ubuntu can be found at https://docs.docker.com/compose/install/​. Basically, you need to run:

``` sh
$​​ sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$​​ 
```

## Git

To install git:

``` sh
$ sudo apt-get install git
```

# JQ

To install jq:

``` sh
$ sudo apt-get install jq
```

## MQTT Client

Our suggestion is to use mosquitto clients, but if you are familiar with other clients, feel free to use them. To install mosquitto clients: 

``` sh
$ sudo apt-get install mosquitto-clients
```

## HTTP Client

Our suggestion is to use curl, but if you are familiar with other tools like postman, feel free to use them. To install curl: 


``` sh
$ sudo apt-get install curl
```

## Javascript Editor
Some of the hands-on will require to develop Javascript code. Our suggestion is to use Visual Studio Code, but feel free a code editor of your preference.

Instructions to install vs code can be found at https://code.visualstudio.com/docs/setup/linux. Basically, you need to run:

``` sh
$ curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
$ sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
$ sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
$
$ sudo apt-get install apt-transport-https
$ sudo apt-get update
$ sudo apt-get install code # or code-insiders
```

# Hands-on

## Use Cases

### Cold-chain monitoring

A company of the cold-chain sector wants to carry out a proof of concept with the dojot platform.
The company wants to monitor their refrigerated trucks (location and temperature) and records when:

 - The temperature reaches values ​​outside an acceptable range.
 - The truck leaves the planned route.

It also wants to send messages from its operational center to the drivers. These notification messages are shown on a display in the trucks.

Messages from device to dojot and vice-versa are sent through MQTT protocol.

### Water quality monitoring

A company produces an IoT device with pollutant and oxygenation level detectors. It will install several of them along a river near a factory to assess the water treatment. Due to the simplicity of the device, it sends the data corresponding to the two measurements (pollutant and oxygenation) in a 16-bit message. Each value is encoded in 8 bits. The data is sent hourly to a gateway that relays it to dojot via HTTP protocol.

A sample message is given bellow:

```
POST /chemsen/readings
{
  "timestamp": 1543449992,            - unix timestamp: 11/29/2018 - 12:06am
   "data": 656,                       - pollutant = 00000010b = 2 | oxygenation = 10010000b = 144
   "device": "PINHR_003"              - unique device identifier
}

```

## Tasks

### Task 1: Start dojot's microservices for the cold-chain monitoring use case

First of all, you need to generate the docker-compose.yml with dojot's microservices. For this, run:

``` sh
./setup.sh -m mqtt
```

This will create docker-compose/docker-compose.yml with mqtt iot-agent enabled.

Then, start the dojot's microsevices:

``` sh
cd docker-compose
sudo docker-compose up -d
cd -
```

Wait for some seconds and run:

``` sh
sudo docker ps
```

All dojot's microservices should be running. If you want to stop them, run:

``` sh
cd docker-compose
sudo docker-compose down
cd -
```

### Task 2: Configure and simulate the cold-chain monitoring use case

The goal of doing this task is to learn how to use dojot's gui and api. 

Before starting, take a look at:

- https://dojotdocs.readthedocs.io/en/latest/using-web-interface.html

- https://dojotdocs.readthedocs.io/en/latest/using-api-interface.html

- https://dojotdocs.readthedocs.io/en/latest/flow.html

- https://dojotdocs.readthedocs.io/en/latest/components-and-apis.html#exposed-apis

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

10. [Extra] Retrieve the devices' data in real time (https://dojot.github.io/data-broker/apiary_latest.html#websockets)
 
### Task 3: Develop an iot-agent for the water quality monitoring use case

The goal of doing this task is to learn how to develop an iot-agent microservice. This is REQUIRED to integrate a device not supported by dojot.

Before starting, go to https://github.com/dojot/iotagent-nodejs and take a look at the documentation.

If you dont't know what to do, don't panic; just follow the steps listed bellow.

#### Step 1: Start a dummy iotagent-http

There is a dummy iotagent-http at samples/iotagent-base. There, you will find:

``` sh
.
├── Dockerfile        - file to build the docker container
├── package.json      - javascript dependencies
├── README.md         - README file
└── src
    └── index.js       - the microservice code

```

First, let's start this microservice:

``` sh
cd sample/iotagent-http-base
sudo docker build -t dojot-training/iotagent-http .
cd -
```

Then you need to regenerate the docker-compose.yml, to include this new microservice, and
start it:

``` sh
./setup.sh -m http
cd docker-compose
sudo docker-compose up -d
cd -
```

Wait some seconds and check its log:

``` sh
cd docker-compose
sudo docker-compose logs -f iotagent-http
cd -
```

You should see some messages that the microservice is running.

To send a HTTP message to this agent, run:

``` sh
DOJOT_HOST="127.0.0.1"
IOTAGENT_PORT=3124
curl -X POST ${DOJOT_HOST}:${IOTAGENT_PORT}/test/data \
-H 'Content-Type:application/json' \
-d '{ "timestamp": 1543449992, "data": 646, "device": "PINHR_003" }'
```

if you check the logs again, you should see that the message has been received.

#### Step 2: Implement your iotagent-http for the water quality monitoring use case

Now, you need to customize the dummy iotagent-http for handling the use case.
Openning the file iotagent-http/src/index.js, you  will see a list of TODOs.
You just need to implement them.

Once you've finished, you need to rebuild and restart the service:

``` sh
cd samples/iotagent-http-base
sudo docker build -t dojot-training/iotagent-http .
cd -
cd docker-compose
sudo docker-compose up -d
cd -
```
Check the logs to see if it's running.

#### Step 3: Test your iotagent-http

Create the template and devices for the water quality monitoring use case. Then, generate some
HTTP messages and validate if they are associated with the corresponding devices.

#### Task 4: Develop a function node for the water quality monitoring use case

The goal here is to learn how to develop function nodes to extend the flowbroker microservice.

You can find instructions how to do this from scratch at https://github.com/dojot/flowbroker/tree/master/lib. So, go there and take a look.

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
    └── index.js            - the decoder logic
```

First, build the container:

``` sh
cd samples/decoder-node-base
sudo docker build -t <flowbroker-node-docker-registry>dojot-training/decoder-node<unique-id> .
cd -
```

Then, push it to the docker registry:

``` sh
cd samples/decoder-node-base
sudo docker push <flowbroker-node-docker-registry>dojot-training/decoder-node<unique-id>
cd -
```

Now, load the node into the flowbroker:

```sh
DOJOT_HOST="http://localhost:8000"
JWT=$(curl -s -X POST ${DOJOT_HOST}/auth -H 'Content-Type:application/json' -d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
curl -X POST -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node -H "content-type: application/json" -d '{"image": "<flowbroker-node-docker-registry>dojot-training/decoder-node<unique-id>", "id":"decoder-node"}'
```
Make sure you have the `jq` installed on your system, otherwise set the `JWT` variable manually.

If you want to remove the node, run:

```sh
DOJOT_HOST="http://localhost:8000"
JWT=$(curl -s -X POST ${DOJOT_HOST}/auth -H 'Content-Type:application/json' -d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
curl -X DELETE -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node/decoder-node
```
Now, you should be able to access the decoder node at the dojot's gui.

#### Step 2: Implement the decoder logic

Openning the file decoder-node-base/src/index.js, you  will see a TODO.
You just need to implement it.

Once you've finished, you need to rebuild the container and push it to the registry. 
So, run:

``` sh
cd samples/decoder-node-base
sudo docker build -t <flowbroker-node-docker-registry>dojot-training/decoder-node<unique-id> .
sudo docker push <flowbroker-node-docker-registry>dojot-training/decoder-node<unique-id>
cd -
```

Now, reloads the node into the flowbroker:

``` sh
DOJOT_HOST="http://localhost:8000"
JWT=$(curl -s -X POST ${DOJOT_HOST}/auth -H 'Content-Type:application/json' -d '{"username": "admin", "passwd" : "admin"}' | jq -r ".jwt")
curl -X DELETE -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node/decoder-node
curl -X POST -H "Authorization: Bearer ${JWT}" ${DOJOT_HOST}/flows/v1/node -H "content-type: application/json" -d '{"image": "<flowbroker-node-docker-registry>dojot-training/decoder-node<unique-id>", "id":"decoder-node"}'
```

#### Step 3: Test your decoder node

Create virtual devices to receive the decoded values and a processing flow for executing the decoder. Then, generate some HTTP messages for the devices and look at the virtual ones to see if the values appeared decoded.