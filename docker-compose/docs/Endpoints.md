# Endpoints

All those endpoints which use JWT encodes its Fiware-Service and Fiware-ServicePath into JWT.

http://middleware-server/gui: access end-user GUI (translates to http://gui:80)
http://middleware-server/metric: access Orion endpoints (translates to http://orion:1026)
http://middleware-server/template: access device manager (translates to http://devm:5000). Uses JWT.
http://middleware-server/device: access device manager (translates to http://devm:5000). Uses JWT.
http://middleware-server/auth: access authorization services (translates to http://auth:5000)
http://middleware-server/auth/user: access user authorization services (translates to http://auth:5000/user). Uses JWT.
http://middleware-server/flows: access orchestrator (translates to http://orch:3000). Uses JWT.
http://middleware-server/history: access Short-Term History (STH) (translates to http://sth/8666)
http://middleware-server/mashup: access mashup nodes service (translates to http://mashup:1880)
