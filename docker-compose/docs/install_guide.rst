Installation guide - Docker compose
===================================

This document provides instructions on how to create a trivial deployment
environment on single host for dojot, using docker-compose as the processes
orchestration platform.

While very simple, this deployment option is best suited to development and
assessment of the platform and should not be used for production environments.

This guide has been checked on an Ubuntu 16.04 LTS environment.

.. contents:: Table of Contents
  :local:

Dependencies
------------

This setup has two software requirements docker engine and docker-compose.

Docker engine
^^^^^^^^^^^^^

Up to date information and installation procedures for the docker engine can
be found at the project's documentation:

https://docs.docker.com/engine/installation/

.. note::

  An optional step on the installation and configuration process of docker on any given
  machine is the setting of who is eligible for creating/spawning docker instances.

  Should the post-installation steps (more specifically the "Manage docker as non-root user")
  have not been run, all docker and docker-compose commands should be run by the super user (root),
  or as sudo.

  https://docs.docker.com/engine/installation/linux/linux-postinstall/

Docker Compose
^^^^^^^^^^^^^^

Up to date information and installation procedures for the docker engine can
be found at the project's documentation:

https://docs.docker.com/compose/install/

Installation
------------

To setup the environment, merely clone the deployment repository and run the
commands below.

The docker-compose enabled deployment scripts and configuration repository
can be found at:

https://github.com/dojot/docker-compose

or as git clone command:::

  git clone git@github.com:dojot/docker-compose.git

Once the repository is properly cloned, select the version to be used by
checking out the appropriate tag (do notice that the tagname has to be replaced): ::

  # Must be run from within the deployment repo
  git checkout [tag name]

.. warning::
  While it should be ok to use the tip of the master branch at dojot/docker-compose,
  be aware that doing so will invariably use the latest versions of all services that
  comprise the platform. As such some, services might still be incompatible with others,
  leading to an unstable environment.

  We strongly suggest new users to try out an stable release first. For a list
  of such releases, please check https://github.com/dojot/docker-compose/releases

After the repository is cloned, and a release (or branch) has been selected, there are still
a few external modules that must be gathered before using the platform. These modules can 
be retrieved by executing the following command: ::

  git submodule update --init --recursive

That done, the environment can be brought up by: ::

  # Must be run from the root of the deployment repo.
  # May need sudo to work: sudo docker-compose up -d
  docker-compose up -d


To check individual container status, docker's commands may be used, for instance: ::

  # Shows the list of currently running containers, along with individual info
  docker ps

  # Shows the list of all configured containers, along with individual info
  docker ps -a

.. note::

  All docker, docker-compose commands may need sudo to work.

  To allow non-root users to manage docker, please check docker's documentation:

  https://docs.docker.com/engine/installation/linux/linux-postinstall/

Configuration
-------------

Once the environment is up, a few configuration steps are required to make it
operational.


API gateway configurarion
^^^^^^^^^^^^^^^^^^^^^^^^^

In order to guarantee the proper mapping of API into processing services,
the API gateway must be configured. To do so, please run kong_config.sh,
present at the root of the repository. ::

  ./kong.config.sh

