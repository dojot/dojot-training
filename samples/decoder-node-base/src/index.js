"use strict";
const path = require('path');
const dojot = require('../../../tasks/decoder-node/src/node_modules/@dojot/flow-node');

// Sample node implementation
class DataHandler extends dojot.DataHandlerBase {
    constructor() {
        super();
    }

    /**
     * Returns full path to html file
     * @return {[string]} [description]
     */
    getNodeRepresentationPath() {
        return path.resolve(__dirname, 'decoder-node.html');
    }

    /**
     * Returns node metadata information
     * This may be used by orchestrator as a liveliness check
     * @return {[type]} [description]
     */
    getMetadata() {
        return {
            // ID can actually be any unique human-friendly string
            // on proper node-red modules it is "$module/$name"
            'id': 'sample/decoder-node',
            // This is usually the name of the node
            'name': 'decoder-node',
            // This is usually the name of the node (as in npm) module
            'module': 'decoder-node',
            'version': '0.0.1',
        };
    }


    /**
     * Returns full path to locales
     * @returns {String} Path segments into an absolute path.
     */
    getLocalesPath() {
        return path.resolve(__dirname, './locales');
    }

    /**
     * Statelessly handle a single given message, using given node configuration parameters
     *
     * This method should perform all computation required by the node, transforming its inputs
     * into outputs. When such processing is done, the node should issue a call to the provided
     * callback, notifying either failure to process the message with given config, or the set
     * of transformed messages to be sent to the flow's next hop.
     *
     * @param  {[type]}       config   Node configuration to be used for this message
     * @param  {[type]}       message  Message to be processed
     * @return {[Promise]}
     */
    handleMessage(config, message) {
        try {

            //TODO: decoder logic

            return Promise.resolve([message]);
        } catch (error) {
            return Promise.reject(error);
        }
    }
}

var main = new dojot.DojotHandler(new DataHandler());
main.init();
