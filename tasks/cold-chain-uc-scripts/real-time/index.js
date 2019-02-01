'use strict'

const ArgumentParser = require('argparse').ArgumentParser;
const axios = require('axios');
const sio = require("socket.io-client");
const util = require("util");

// Arguments parsing ...
const parser = new ArgumentParser(
    {
        version: '0.0.1',
        addHelp:true,
        description: 'Example of realtime client for dojot',
        prog: 'node index.js',
        usage: 'Usage %(prog)s <args>'
    }
);
const requiredArgs = parser.addArgumentGroup(
    { 
        title: 'required arguments' 

    });

// host
requiredArgs.addArgument(
    [ '-U', '--url' ],
);

// user
requiredArgs.addArgument(
    [ '-u', '--user' ],
)

// password
requiredArgs.addArgument(
    [ '-p', '--password' ],
)

// parse arguments
const args = parser.parseArgs();
if(!(args.url && args.user && args.password)) {
    parser.printHelp();
    process.exit(1);
}

// Get dojot api token
function getApiToken(url, user, password) {
    return new Promise((resolve, reject) => {
        axios({
            method: 'POST',
            headers: {
                        'Content-Type': 'application/json'
                     },
            url: `${url}/auth`,
            data: JSON.stringify({
                                    'username': user,
                                    'passwd': password
                                 }),
            timeout: 5000
        }).then(response => {
            resolve(response.data.jwt);
        }).catch(error => {
            reject(error);
        });
    });
}

// Get dojot socket.io token
function getSocketioToken(url, apiToken) {
    return new Promise((resolve, reject) => {
        axios({
            method: 'GET',
            headers: {
                        'Authorization': `Bearer ${apiToken}`
                     },
            url: `${url}/stream/socketio`,
            timeout: 5000
        }).then(response => {
            resolve(response.data.token);
        }).catch(error => {
            reject(error);
        });
    });
}

getApiToken(args.url, args.user, args.password)
.then(apiToken => {
    getSocketioToken(args.url, apiToken)
    .then(token => {
        try {
            const query = {
                            query: { token },
                            transports: ["websocket"]
                        };
            
            console.info('Establishing socket.io connection ...');
            let socketIO = sio(args.url, query);
            console.info('Listening to socket.io ...');
            socketIO.on("all", (data) => {
                console.info(`Received message ${util.inspect(data)}`);
            });
        }
        catch(error) {
            console.error(`Failed to establish socket.io connection!`);
            process.exit(1);
        }
    }).catch(error => {
        console.error(`Failed to get socket.io Token (${error}).`);
        process.exit(1);
    });

}).catch(error => {
    console.error(`Failed to get API Token (${error}).`);
    process.exit(1);
});