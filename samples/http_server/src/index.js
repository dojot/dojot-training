'use strict';

const Express = require('express');
const bodyParser = require('body-parser');

let server = Express();
server.use(bodyParser.json()); // for parsing application/json
let port = 3100;

server.post('/hello', (req, res) => {

	let name = req.body.name;
	if (!name) {
		res.status(400).send({'message': 'missing name'});
		return;
	}

	res.status(200).send({'message': "Hello " + name});
});


server.listen(port, () => {
    console.log(`HTTP server listening on port ${port}!`);
});
