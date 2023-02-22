Build scripts for Total Compute stack
=====================================

This README is simply a quick-start guide on the build scripts themselves. For more
information on how to obtain and run the Total Compute stack, please refer to
the user guide.

Pre-requisites
--------------
Install and allow access to docker
```sh
sudo apt install docker.io
sudo chmod 777 /var/run/docker.sock
```

Login to docker container registry to push an image to the registry
```sh
docker login registry.gitlab.arm.com
```

Setup
-----
Setup includes two parts:
1. Pull/Build a Docker image from Container registry
2. Setup the environmet to build TC images

To pull/build a docker image, patch the components and install the toolchains and build tools, run:

For Buildroot:
```sh
export PLATFORM=tc2
export FILESYSTEM=buildroot
./setup.sh
```

For Android:
```sh
export PLATFORM=tc2
export FILESYSTEM=android-swr
./setup.sh
```

For Android with AVB (Android Verified Boot):
```sh
export PLATFORM=tc2
export FILESYSTEM=android-swr
export AVB=true
./setup.sh
```

Build the stack
---------------

To build the whole stack:
```sh
./run_docker.sh ./build-all.sh build
```

The platform and filesystem should already have been defined, but if not they can be defined on the command line using:
```sh
./run_docker.sh ./build-all.sh -p $PLATFORM -f $FILESYSTEM -a $AVB build
```

To build each component separately, run the corresponding script with the exact
same options.

Each script supports build, clean, patch and deploy commands.
build-all.sh also support the `all` command, for a clean complete build +
deploy.

Build files will be in output/tmp_build/$COMPONENT
The deployed binaries are then copied to output/deploy/$PLATFORM


Build Components and its dependencies
-------------------------------------

A new dependency to a component can be added in the form of $component=$dependency in dependencies.txt file

To build a component and rebuild those components that depend on it
```sh
./run_docker.sh ./$filename build with_reqs
```

Kernel Selftest
-------------------------------------

Test are located at /usr/bin/selftest on device

To run all the tests in one go, use run_selftest.sh script. Tests can be run individually also.
```sh
./run_kselftest --summary
```

Run FVP model from docker container
-----------------------------------

To run FVP model in docker container , either of the steps can be followed

Option1:
        - Copy the parent model directory into your tc-workspace directory where build-scripts, run-scripts, src are present.
        - Please provide absolute path to the model binary, relative path doesn't work.

Option2:
        - Mount the model directory to container by adding "-v <Absolute path to model top directory>:<Absolute path to model top directory> in run_docker.sh
        - Ex: -v 11.19/:11.19/

To run FVP in docker container export required licenses and run:
```sh
./run_docker.sh run_model -m Absolute_path_to_model -d distro_opts
```
