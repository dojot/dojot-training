#!/bin/sh -ex

# ---  0.10.x
kong="http://apigw:8001"

authConfig() {
  curl -o /dev/null -sS -X POST ${kong}/apis/${1}/plugins -d "name=jwt" # -d "config.claims_to_verify=exp"
  curl -o /dev/null -sS -X POST ${kong}/apis/${1}/plugins -d "name=pepkong" -d "config.pdpUrl=http://auth:5000/pdp"
}

# remove all previously configured apis from gateway
for i in $(curl -sS ${kong}/apis  | grep -o -E '"id":"([a-f0-9-]+)"' | cut -f4 -d'"'); do
  curl -o /dev/null -sS -X DELETE ${kong}/apis/${i}
done

(curl -o /dev/null ${kong}/apis -sS -X PUT \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "gui",
    "uris": "/",
    "strip_uri": false,
    "upstream_url": "http://gui:80"
}
PAYLOAD
# no auth: serves only static front-end content

(curl -o /dev/null ${kong}/apis -sS -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "data-broker",
    "uris": ["/device/(.*)/latest", "/subscription"],
    "strip_uri": false,
    "upstream_url": "http://data-broker:80"
}
PAYLOAD
authConfig "data-broker"
(curl -o /dev/null ${kong}/apis -sS -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "data-streams",
    "uris": ["/stream"],
    "strip_uri": true,
    "upstream_url": "http://data-broker:80"
}
PAYLOAD
authConfig "data-streams"
(curl -o /dev/null $kong/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "ws-http",
    "uris": "/socket.io",
    "strip_uri": false,
    "upstream_url": "http://data-broker:80"
}
PAYLOAD

(curl -o /dev/null ${kong}/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "device-manager",
    "uris": ["/device", "/template"],
    "strip_uri": false,
    "upstream_url": "http://device-manager:5000"
}
PAYLOAD
authConfig "device-manager"


(curl -o /dev/null ${kong}/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "image",
    "uris": "/fw-image",
    "strip_uri": true,
    "upstream_url": "http://image-manager:5000"
}
PAYLOAD
authConfig "image"


(curl -o /dev/null ${kong}/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "auth-service",
    "uris": "/auth",
    "strip_uri": true,
    "upstream_url": "http://auth:5000"
}
PAYLOAD
# no auth: this is actually the endpoint used to get a token
# rate plugin limit to avoid brute-force atacks
curl -o /dev/null -sS -X POST ${kong}/apis/auth-service/plugins \
    --data "name=rate-limiting" \
    --data "config.minute=5" \
    --data "config.hour=40" \
    --data "config.policy=local"


# revoke all tokens: maintence only API
(curl -o /dev/null ${kong}/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "auth-revoke",
    "uris": "/auth/revoke",
    "strip_uri": false,
    "upstream_url": "http://auth:5000"
}
PAYLOAD
curl -o /dev/null -sS -X POST  ${kong}/apis/auth-revoke/plugins \
    --data "name=request-termination" \
    --data "config.status_code=403" \
    --data "config.message=Not authorized"


(curl -o /dev/null ${kong}/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "user-service",
    "uris": "/auth/user",
    "strip_uri": true,
    "upstream_url": "http://auth:5000/user"
}
PAYLOAD
authConfig "user-service"

# -- end auth service --
# flows service configuration

(curl -o /dev/null ${kong}/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "flows",
    "uris": ["/flows"],
    "strip_uri": true,
    "upstream_url": "http://flowbroker:80"
}
PAYLOAD
authConfig "flows"
# authConfig "flows"

(curl -o /dev/null ${kong}/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "flows-assets",
    "uris": ["/flows/icons"],
    "strip_uri": true,
    "upstream_url": "http://flowbroker:80/icons"
}
PAYLOAD

# -- end mashup/flows --

(curl -o /dev/null ${kong}/apis -s -S -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
    "name": "history",
    "uris": "/history",
    "strip_uri": true,
    "upstream_url": "http://history:8000"
}
PAYLOAD
authConfig "history"

# CA certificate retrievemment and certificate sign requests
(curl -o /dev/null ${kong}/apis -sS -X POST \
    --header "Content-Type: application/json" \
    -d @- ) <<PAYLOAD
{
     "name": "ejbca-paths",
     "uris": [ "/sign", "/ca"],
     "strip_uri": false,
     "upstream_url": "http://ejbca:5583/"
 }
PAYLOAD
authConfig "ejbca-paths"
