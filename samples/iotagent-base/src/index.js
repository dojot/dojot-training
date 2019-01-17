'use strict';

// Libraries
const IotAgent = require('@dojot/iotagent-nodejs');
const Express = require('express');
const bodyParser = require('body-parser');

const SERVER_PORT = process.env.SERVER_PORT || 3124;

// Initialize the IoT Agent.
let iotAgent = new IotAgent.IoTAgent();
iotAgent.init().then( () => {
    console.log('Succeeded to start the HTTP IoT Agent ');

    // Handle device.create event
    iotAgent.messenger.on('iotagent.device', 'device.create', (tenant, event) => {
        console.log(`Received device.create event ${event} for tenant ${tenant}.`);
        // TODO handle this event
    });
    
    // Handle device.update event
    iotAgent.messenger.on('iotagent.device', 'device.update', (tenant, event) => { 
        console.log(`Received device.update event ${event} for tenant ${tenant}.`);
        // TODO handle this event
    });

    // Handle device.remove event
    iotAgent.messenger.on('iotagent.device', 'device.remove', (tenant, event) => {
        console.log(`Received device.update event ${event} for tenant ${tenant}.`);
        // TODO handle this event
    });

    // force device.create events for devices created before starting the iotagent
    iotAgent.messenger.generateDeviceCreateEventForActiveDevices();
  
    // HTTP server
    server = Express();
    server.use(bodyParser.json());

    // handle HTTP post
    server.post('/test/data', (req, res) => {

        console.log(`Received HTTP message: $(JSON.stringify(req.body))`);

        // TODO: validate the message.
        // res.status(400).send({'message': 'missing x attribute'});
        // return;


        // TODO: validate if the message belongs to some device
        // res.status(400).send('message': 'not found the device associated with this message');
        // return;

        // TODO: generate the internal message
        // let tenant = '';    // the tenant associated with the device
        // let deviceId = '';  // the device identifier in dojot
        // let msg = {};       // dictionary of dynamic attributes
        // let metada = {};    // dictionary of metada, here you can, for instance, overwrite the timestamp

        // send data to dojot internal services
        // iotAgent.updateAttrs(deviceId, tenant, msg, metada);

        // 204 - Success/No content
        res.status(204).send();
    });

    // start HTTP server
    this._server.listen(SERVER_PORT, () => {
        console.log(`IotAgent HTTP listening on port ${SERVER_PORT}!`);
    });

}).catch( () => {
    console.log('Failed to initialize the HTTP IoT Agent');
    process.exit(1);
});
