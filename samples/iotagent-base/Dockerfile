FROM dojotraining/dojot-training:training-122018

WORKDIR /dojot/nodejs

ENV LD_LIBRARY_PATH=/dojot/nodejs/node_modules/node-rdkafka/build/deps/

COPY src ./src
CMD ["node", "src/index.js"]
