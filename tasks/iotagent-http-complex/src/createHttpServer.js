const http = require('http');

function createHttpServer({ webFramework, logger }) {
  // creates HTTP server
  const httpServer = http.createServer();

  httpServer.on('listening', () => {
    // event emitted when the server is listening on the chosen port
    logger.info('HTTP Server ready to accept connections!', httpServer.address());
  });

  httpServer.on('error', (err) => {
    // event emitted when an error occurs with the server
    // e.g. Chosen port is already in use by another process
    logger.error('HTTP Server experienced an error:', err);
    if (err.code === 'EADDRINUSE') {
      throw err;
    }
  });

  httpServer.on('close', () => {
    // event emitted when all connections are closed
    logger.info('All connections to the HTTP server have been closed!');
  });

  // adds the request handler to the http server
  httpServer.on('request', webFramework);

  return httpServer;
}

module.exports = createHttpServer;
