const { Logger } = require('@dojot/microservice-sdk');
const CustomIoTAgent = require('./CustomIoTAgent');
const createWebFramework = require('./createWebFramework');
const createHttpServer = require('./createHttpServer');
const Terminator = require('./Terminator');

Logger.setTransport('console', {
  level: process.env.LOG_LEVEL || 'info',
});
Logger.setVerbose(false);

const logger = new Logger('IoTAgent (main)');

const iotAgent = new CustomIoTAgent({ logger });

const webFramework = createWebFramework({ iotAgent, logger });

const httpServer = createHttpServer({ webFramework, logger });

const terminator = new Terminator({
  iotAgent,
  httpServer,
  logger,
});

// starts the IoT agent
iotAgent.launch();

// run the server on the chosen port
const serverPort = parseInt((process.env.SERVER_PORT || 3000), 10);
httpServer.listen(serverPort);

// listen for signals emitted by the operating system
terminator.listen();

// lib @dojot/dojot-module-logger configures the Winston
// logger transport to handle unhandled exceptions.
// This behavior is not desired for this application.
process.removeAllListeners('uncaughtException');
