# How to build the image
``` sh
sudo docker build -t sample_http_server .
```

# How to run
``` sh
sudo docker run -p 3100:3100 sample_http_server
```

# How to send a request
```sh
curl -X POST http://localhost:3100/hello -H 'Content-Type:application/json' -d '{ "name": "dojot" }'
```
