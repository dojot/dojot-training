# About
This repository is the workspace for the Dojot's training.

## Allowing an insecure registry
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

## Configuring private docker registry
``` sh
./setup.sh http <private-docker-registry-ip>:<private-docker-registry-port>
```

## Build a dummy service as iotagent-http
Execute:
``` sh
cd samples/base
sudo docker build -t dojot-training/iotagent-http .
cd -
```

## Start Dojot's services
``` sh
cd docker-compose
sudo docker-compose up -d
cd -
```
 
Wait some seconds and check the log:
``` sh
sudo docker-compose logs -f iotagent-http
```

## Stop Dojot's services
``` sh
cd docker-compose
sudo docker-compose down
```