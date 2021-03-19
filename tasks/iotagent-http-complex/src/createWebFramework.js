const express = require('express');

/* This library is about what happens when you hit an async error. */
require('express-async-errors');

const createRequestIdMiddleware = require('express-request-id');

const { StatusCodes } = require('http-status-codes');
const { WebUtils, Logger } = require('@dojot/microservice-sdk');

const { defaultErrorHandler, errorTemplate } = WebUtils.framework;

function validateMandatoryFields(request) {
  request.logger.info('Validating mandatory fields...');

  const fields = ['timestamp', 'data', 'device'];
  fields.forEach((f) => {
    if (!Object.prototype.hasOwnProperty.call(request.body, f)) {
      const errMsg = `Missing mandatory field: ${f}`;
      request.logger.error(errMsg);
      throw errorTemplate.BadRequest(errMsg);
    }
  });

  if (!Number.isInteger(request.body.data) || request.body.data < 0) {
    const errMsg = 'Reading data is not in a valid format. It must be a positive integer number!';
    request.logger.error(errMsg);
    throw errorTemplate.BadRequest(errMsg);
  }

  request.logger.info('mandatory fields have been validated!');
}

function createWebFramework({ iotAgent, logger }) {
  const webFramework = express();

  // Generate UUID for request and add it to 'X-Request-Id' header.
  webFramework.use(createRequestIdMiddleware());

  // Parses JSON when the Content-Type header is equal to "application/json"
  webFramework.use(express.json({ limit: '100kb' }));

  // custom interceptor to create a new Logger per request
  webFramework.use((req, res, next) => {
    req.logger = new Logger(`IoTAgent - Request-Id:${req.id}`);
    next();
  });

  webFramework.post('/upload', async (request, response) => {
    request.logger.info('Received request data:', { body: request.body });

    validateMandatoryFields(request);

    const { tenant } = request.headers;
    const { timestamp, data, device } = request.body;

    const scopedIoTAgent = iotAgent.scoped({ logger: request.logger });
    await scopedIoTAgent.uploadData({
      tenant, deviceId: device, data, timestamp,
    });

    response.status(StatusCodes.NO_CONTENT).send();
  });

  webFramework.get('/download/:deviceId', async (request, response) => {
    const { tenant } = request.headers;
    const { deviceId } = request.params;

    const scopedIoTAgent = iotAgent.scoped({ logger: request.logger });
    const data = await scopedIoTAgent.downloadData({ tenant, deviceId });

    if (data) {
      response.status(StatusCodes.OK).json({ data });
    } else {
      response.status(StatusCodes.NO_CONTENT).send();
    }
  });

  // catch invalid request (404-Not Found) and forward to error handler
  webFramework.use((req, res, next) => {
    next(errorTemplate.NotFound());
  });

  // custom error handler
  webFramework.use(defaultErrorHandler({ logger }));

  return webFramework;
}

module.exports = createWebFramework;
