# IoTAgent HTTP in more detail

This example attempts to address the fundamental characteristics of an IoT Agent
in more detail. It serves as a complementary study and is based on the same
_use case_ as the
[water quality monitoring](../../README.md#water-quality-monitoring) scenario.

This example can be opened in the [VS Code](https://code.visualstudio.com/)
editor, including a [configuration file](./.vscode/launch.json) used by VS Code
for debugging that can be useful to help you run the code outside the dojot
[docker-compose](https://github.com/dojot/docker-compose/blob/v0.5.2/docker-compose.yml)
environment.

This example uses _Node.js_ version `12.21.0`. Therefore, it would be
interesting to have the [NVM](https://github.com/nvm-sh/nvm) (Node Version
Manager) installed on your computer.

Basically, you must attend to the _version_ of Node.js and have installed the
_build-essential_ library (in the case of Linux distributions based on Debian).
It is likely that in order to compile the `node-rdkafka` _node_module_ it will
be necessary to install the _gzip compression_ library. In this case, the most
advisable is to study the dependencies declared in the [Dockerfile](./Dockerfile)
file to have an idea of what is needed.

To install the project's dependencies and generate the _node_modules_ folder,
there is no secret, just run the [NPM](https://www.npmjs.com/) command in the
project's root directory (the one where the `package.json` file is located) as
follows:

~~~shell
$ npm install
~~~

To run this example through _VS Code_ and access the containers within the dojot
_docker-compose_ environment, it is necessary to externalize the ports of some
microservices, that is,
[map them](https://docs.docker.com/compose/compose-file/compose-file-v3/#ports)
as _localhost_ ports. Being them:

 - `auth`: From container port `5000` to localhost port `5858`;
 - `data-broker`: From container port `80` to localhost port `3838`;
 - `device-manager`: From container port `5000` to localhost port `5757`;
 - `kafka`: From container port `9092` to localhost port `9092`;

If the _localhost_ ports are already in use by other processes, it is okay to
change them, remembering that you will also need to change the
_debug configuration file_ of VS Code.

There is a detail regarding the connection to Kafka's microservice. for this
microservice it is necessary to map the _domain name_ `kafka` in the
`/etc/hosts` file. That is, in order for the example (running locally) to be
able to connect to _Kafka_ (inside the docker-compose), in addition to
externalizing the Kafka container port to your localhost, it is also necessary
to edit the `/etc/hosts` file on your Linux:

~~~shell
$ sudo vi /etc/hosts
~~~

And include the following entry:

~~~
127.0.0.1 kafka
~~~

This way, your local DNS will know how to correctly resolve the _domain name_
for the _kafka_ service.

## Code architecture

The example code is organized in _layers_ (like an onion), The `Gateway`
(located outside the dojot) makes requests to our `HTTP server` provided by the
native libraries of Node.js. The `HTTP server` receives the request and tries
to forward the request to the _Request Handler_ that has been assigned to it.
The role of _Request Handler_ is the Express.js `Web Framework` (but it could be
any other). The `Web Framework` is able to communicate correctly with our custom
`IoT Agent`, which in turn has an internal `Kafka Client` fully adapted to
_produce_ and _consume_ messages on the correct _Kafka topics_. Whenever the
`IoT Agent` produces data through the `Kafka client`, it will be consumed by the
other _dojot microservices_. In contrast, whenever _dojot_ publishes data on
topics that the `IoT Agent` monitors, they will be consumed by the
`kafka client` within the `IoT Agent`, having the ability to properly process
the data.
There is an object `Terminator` at the bottom of the layers that has the
responsibility to  correctly _end_ the Node.js process, that is, it is the one
that receives the signals `SIGTERM`, `SIGHUP` and `SIGINT` that the Docker sends
to the container when it must be _stopped_ (before the period of
_graceful shutdown_ runs out and the process is _killed_ by the Docker).
Basically this object _closes the sockets_ that were opened by the
`Kafka Client` and the `HTTP server`.

```
                 ╔══════════════════════════════════════╗
                 ║██[ Docker Container ]████████████████║
                 ╠══════════════════════════════════════╣
                 ║▓▓[ Node.js process  ]▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓║
╔═════════╗      ║   ┌────────────────────────────────┐ ║
║ Gateway ╠>────<╬>┐ │▒▒[ HTTP Server ]▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│ ║
╚═════════╝      ║ │ │   ┌──────────────────────────┐ │ ║
                 ║ └─┼─┐ │░░[ Web Framework ]░░░░░░░│ │ ║
                 ║   │ │ │   ┌────────────────────┐ │ │ ║
                 ║   │ └─┼─┐ │■■[ IoT Agent ]■■■■■│ │ │ ║
                 ║   │   │ │ │   ┌──────────────┐ │ │ │ ║      ╔═══════╗
                 ║   │   │ └─┼───┤ Kafka Client ├─┼─┼─┼<╬>────<╣ Kafka ║
                 ║   │   │   │   └──────────────┘ │ │ │ ║      ╚═══════╝
                 ║   │   │   └────────────────────┘ │ │ ║
                 ║   │   └──────────────────────────┘ │ ║
                 ║   └────────────────────────────────┘ ║
                 ║   ┌────────────────────────────────┐ ║
                 ║   │▒▒[ Terminator ]▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒│ ║
                 ║   └────────────────────────────────┘ ║
                 ╚══════════════════════════════════════╝
```
