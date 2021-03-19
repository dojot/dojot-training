const { WebUtils } = require('@dojot/microservice-sdk');
const { IoTAgent } = require('@dojot/iotagent-nodejs');
const { logger: iotAgentLogger } = require('@dojot/dojot-module-logger');

iotAgentLogger.setLevel(process.env.LOG_LEVEL || 'info');

const { errorTemplate } = WebUtils.framework;

function binToStr(typedArray) {
  const bitLength = typedArray.BYTES_PER_ELEMENT * 8;
  const bin = typedArray.reduce((str, byte) => str + byte.toString(2).padStart(bitLength, '0'), '');
  return bin.match(/.{8}/g).join(' ');
}

class CustomIoTAgent extends IoTAgent {
  constructor({ logger }) {
    super();
    this.logger = logger;
    this.localStorage = new Map();
    this.dataToDownload = new Map();
  }

  /**
   * Starts the IoT agent
   */
  async launch() {
    this.logger.info('Starting IoT agent...');

    await this.init();

    this.messenger.on('iotagent.device', 'device.create', (tenant, event) => { this.onCreateDevice(event); });

    this.messenger.on('iotagent.device', 'device.update', (tenant, event) => { this.onUpdateDevice(event); });

    this.messenger.on('iotagent.device', 'device.remove', (tenant, event) => { this.onDeleteDevice(event); });

    this.messenger.generateDeviceCreateEventForActiveDevices();

    this.logger.info('IoT agent started!');
  }

  /**
   * terminates the IoT agent
   */
  async shutdown() {
    this.logger.info('terminating the IoT agent...');

    await this.terminate();

    this.logger.info('IoT agent terminated!');
  }

  /**
   * Returns a lightweight copy of this object with
   * some attributes belonging to a different scope
   */
  scoped({ logger }) {
    const lightweightCopy = Object.create(this);
    return Object.assign(lightweightCopy, this, { logger });
  }

  onCreateDevice(event) {
    const tenant = event.meta.service;
    const device = event.data;
    const deviceKey = `${tenant}:${device.id}`;

    this.localStorage.set(deviceKey, device);

    this.logger.info('New device created', { deviceKey });
  }

  onUpdateDevice(event) {
    const tenant = event.meta.service;
    const device = event.data;
    const deviceKey = `${tenant}:${device.id}`;

    const deviceEntity = this.localStorage.get(deviceKey);
    if (deviceEntity && (deviceEntity.label === device.label)) {
      this.logger.info('Device name continues the same', { deviceKey });
      return;
    }
    // the device name has been changed
    // update the IoT agent Repository
    this.localStorage.set(deviceKey, device);

    // put the data on the download map
    // so the device can pick up afterwards
    this.dataToDownload.set(deviceKey, device.label);

    this.logger.info('A device has been changed', { deviceKey });
  }

  onDeleteDevice(event) {
    const tenant = event.meta.service;
    const device = event.data;
    const deviceKey = `${tenant}:${device.id}`;

    const deviceEntity = this.localStorage.get(deviceKey);
    if (deviceEntity) {
      this.localStorage.delete(deviceKey);

      this.logger.info('A device has been removed', { deviceKey });
    }
  }

  /**
   * processes messages sent by devices
   */
  uploadData({
    tenant, deviceId, data, timestamp,
  }) {
    this.logger.info('Checking device information...');

    const deviceKey = `${tenant}:${deviceId}`;
    const deviceEntity = this.localStorage.get(deviceKey);
    if (!deviceEntity) {
      throw errorTemplate.NotFound(`Discarding message to unknown device: ${deviceKey}`);
    }
    this.logger.info('device information has been verified!', { deviceKey });

    // Obtains a sequence of the rightmost (less significant) 16 bits. Extra bits are cut-off.
    const uint16Array = new Uint16Array([data]);
    this.logger.info(`Device data (binary) ${binToStr(uint16Array)}`, { deviceKey });

    // DataView allows to access the data on any offset in any format
    const dataView = new DataView(uint16Array.buffer);

    const payload = {
      timestamp,
      pollutant: dataView.getUint8(1),
      oxygen: dataView.getUint8(0),
    };

    this.updateAttrs(deviceEntity.id, tenant, payload, {});

    this.logger.info('upload completed', { deviceKey, payload });
  }

  /**
   * Provides data to be downloaded to devices
   */
  downloadData({ tenant, deviceId }) {
    const deviceKey = `${tenant}:${deviceId}`;

    const deviceEntity = this.localStorage.get(deviceKey);
    if (!deviceEntity) {
      throw errorTemplate.NotFound(`Unknown device: ${deviceKey}`);
    }

    const data = this.dataToDownload.get(deviceKey);
    if (!data) {
      this.logger.info('No data to be downloaded.', { deviceKey });
      return null;
    }

    // After downloading the data, we can remove it from the waiting list
    this.dataToDownload.delete(deviceKey);

    this.logger.info('Data to be downloaded to the device', { deviceKey, data });
    return data;
  }
}

module.exports = CustomIoTAgent;
