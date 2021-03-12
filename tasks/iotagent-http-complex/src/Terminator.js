class Terminator {
  constructor({ iotAgent, httpServer, logger }) {
    this.signals = ['SIGTERM', 'SIGHUP', 'SIGINT'];
    this.iotAgent = iotAgent;
    this.httpServer = httpServer;
    this.logger = logger;
  }

  listen() {
    this.signals.forEach((signal) => {
      process.on(signal, async () => {
        // programmatically exiting
        this.logger.info('Start of the application shutdown process...');

        // We recommend that the HTTP server be terminated in a more elaborate way,
        // but that it was not covered in this example for the sake of simplicity.
        await new Promise((resolve, reject) => {
          this.httpServer.close((err) => {
            if (err) {
              reject(err);
            } else {
              resolve();
            }
          });
        });

        await this.iotAgent.shutdown();

        // Check that there is nothing else pending in
        // the Event Loop before assuming it is empty...
        // process._getActiveHandles();
        // process._getActiveRequests();

        this.logger.info('Application shutdown process completed!');
      });
    });
  }
}

module.exports = Terminator;
