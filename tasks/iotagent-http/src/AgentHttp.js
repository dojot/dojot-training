'use strict';

const Express = require('express');
const bodyParser = require('body-parser');

function validateMandatoryFields(body, fields) {
    for (let f of fields) {
        if (!body.hasOwnProperty(f)) {
            return "Missing mandatory field: " + f;
        }
    }
}

module.exports = class AgentHttp {
    constructor(iotAgent, port) {
        console.log('HTTP server will use port: ', port);
        this._dojotDevicesInfo = {};
        this._mapDojotIdToDeviceName = {};
        this._iotAgent = iotAgent;
        this._port = port;
        this._server = null;
    }

    init() {
        this._iotAgent.messenger.on('iotagent.device', 'device.create',
            (tenant, event) => { this._onCreateDevice(event) });
        this._iotAgent.messenger.on('iotagent.device', 'device.update',
            (tenant, event) => { this._onUpdateDevice(event) });
        this._iotAgent.messenger.on('iotagent.device', 'device.remove',
            (tenant, event) => { this._onDeleteDevice(event) });

        this._iotAgent.messenger.generateDeviceCreateEventForActiveDevices();

        this._server = Express();
        this._server.use(bodyParser.json()); // for parsing application/json

        this._server.post('/chemsen/readings', (req, res) => {

            const error = validateMandatoryFields(req.body, ['timestamp', 'data', 'device']);
            if (error) {
              return res.status(400).send({'message': error});
            }

            console.log("Received: ", req.body);
            this._handleDeviceMessage(req.body.timestamp,
                req.body.data,
                req.body.device);
            res.status(204).send();
        });

        return new Promise ( (resolve, reject) => {
            this._server.listen(this._port, () => {
                console.log(`IotAgent HTTP listening on port ${this._port}!`);
                resolve();
            });
        });
    }

    _onCreateDevice(event) {
        let tenant = event.meta.service;
        let deviceId = event.data.id;
        let deviceName = event.data.label;

        this._dojotDevicesInfo[deviceName] = {
            tenant,
            deviceId
        };

        this._mapDojotIdToDeviceName[tenant + ":" + deviceId] = deviceName;
    }

    _onUpdateDevice(event) {
        let tenant = event.meta.service;
        let deviceId = event.data.id;
        let deviceName = event.data.label;

        let previousDeviceName = this._mapDojotIdToDeviceName[tenant + ":" + deviceId];
        if ( (previousDeviceName) && (previousDeviceName === deviceName) ) {
            // device name continues the same
            return;
        }

        // the device name has been changed

        // update the map
        this._mapDojotIdToDeviceName[tenant + ":" + deviceId] = deviceName;

        // remove the previous device info
        delete this._dojotDevicesInfo[previousDeviceName];

        // add the band new info
        this._dojotDevicesInfo[deviceName] = {
            tenant,
            deviceId
        };
    }

    _onDeleteDevice(event) {
        let deviceName = this._mapDojotIdToDeviceName[event.meta.service + ':' + event.data.id];
        if (deviceName) {
            delete this._dojotDevicesInfo[deviceName];
            delete this._mapDojotIdToDeviceName[event.meta.service + ':' + event.data.id];
        }
    }

    _handleDeviceMessage(timestamp, data, deviceName) {

        let dojotDeviceInfo = this._dojotDevicesInfo[deviceName];
        if (!dojotDeviceInfo) {
            console.log('Discarding message to unknown device: ', deviceName);
            return;
        }

        let jsonData = {
            timestamp,
            data,
            device: deviceName
        };

        this._iotAgent.updateAttrs(dojotDeviceInfo.deviceId,
            dojotDeviceInfo.tenant,
            jsonData,
            { } // metadata
        );
    }

}
