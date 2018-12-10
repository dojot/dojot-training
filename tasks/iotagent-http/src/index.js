'use strict';

var IotAgent = require('@dojot/iotagent-nodejs');
var AgentHttp = require('./AgentHttp');

let iotAgent = new IotAgent.IoTAgent();
iotAgent.init().then( () => {
    let httpServerPort = process.env.SERVER_PORT || 3124;
    let httpServer = new AgentHttp(iotAgent, httpServerPort);
    httpServer.init(() => {

    });
}).catch( () => {
    console.log('Failed to initialize the basic IoT agent');
    process.exit(1);
});
