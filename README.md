# Build scripts for Total Compute stack

This README is simply a quick-start guide on the build scripts themselves. For more
information on how to obtain and run the Total Compute stack, please refer to
the user guide.

## Prerequisites
-------------
Install and allow access to docker
```bash
sudo apt install docker.io
sudo chmod 777 /var/run/docker.sock
```

## Setup
-----
Setup includes two parts:
1. Pull/Build a Docker image from Container registry;
2. Setup the environment to build TC images.

Setting up a docker image involves pulling the prebuilt docker image from a docker registry. If that fails, it will build a local docker image.

To setup a docker image, patch the components, install the toolchains and build tools, please run the following listed commands according to the distro and variant of interest.

The various tools will be installed in the ``<TC2_WORKSPACE>/tools/`` directory.

## Build options
-------------

### Debian OS build variant

Currently, the Debian OS build distro support is limited to Mali GPU hardware rendering based on DDK source code compilation, by explicitly setting the build environment variable as ``TC_GPU=hwr``.

**Note:** GPU DDK source code is available only to licensee partners (please contact support@arm.com).

### Android OS build variants

**Note:** Android based stack takes considerable time to build, so start the build and go grab a cup of coffee!

#### Hardware vs Software rendering


The Android OS based build distro supports the following variants regarding the use of the GPU rendering:


| TC_GPU value | Description                                                                    |
|:------------:|:-------------------------------------------------------------------------------|
| swr          | Android display with Swiftshader (software rendering)                          |
| hwr          | Mali GPU (hardware rendering based on DDK source code - please see below note) |
| hwr-prebuilt | Mali GPU (hardware rendering based on prebuilt binaries)                       |


If not explicitly defined by the user, the default value used for the ``TC_GPU`` environment variable is ``hwr-prebuilt``.

**Note:** GPU DDK source code is available only to licensee partners (please contact support@arm.com).

#### Android Verified Boot (AVB) with/without authentication

The Android images can be built with or without authentication enabled using Android Verified Boot (AVB) through the use of the ``-a`` option.
AVB build is done in userdebug mode and takes a longer time to boot as the images are verified.
This option does not influence the way the system boots, rather it adds an optional sanity check on the prerequisite images.


## Build variants configuration
----------------------------

For the Buildroot build:
```bash
export PLATFORM=tc2
export FILESYSTEM=buildroot
export TC_TARGET_FLAVOR=fvp
cd build-scripts
./setup.sh
```

For the Android build with hardware rendering based on prebuilt binaries:
```bash
export PLATFORM=tc2
export FILESYSTEM=android-fvp
export TC_GPU=hwr-prebuilt
export TC_TARGET_FLAVOR=fvp
export ARMCLANG_TOOL=<PATH TO ARMCLANG TOOLCHAIN>
cd build-scripts
./setup.sh
```

For the Android build with hardware rendering based on DDK source code:
```bash
export PLATFORM=tc2
export FILESYSTEM=android-fvp
export TC_GPU=hwr
export TC_TARGET_FLAVOR=fvp
export GPU_DDK_REPO=<PATH TO GPU DDK SOURCE CODE>
export GPU_DDK_VERSION="releases/r41p0_01eac0"
export LM_LICENSE_FILE=<LICENSE FILE>
export ARM_PRODUCT_DEF=<PATH TO ELMAP FILE IN ARMCLANG>
export ARMLMD_LICENSE_FILE=<LICENSE FILE>
export ARMCLANG_TOOL=<PATH TO ARMCLANG TOOLCHAIN>
./setup.sh
```

For the Android build with software rendering:
```bash
export PLATFORM=tc2
export TC_GPU=swr
export TC_TARGET_FLAVOR=fvp
export FILESYSTEM=android-fvp
./setup.sh
```


## Build the stack
---------------

To build the whole TC2 software stack, simply run:
```bash
./run_docker.sh ./build-all.sh build
```
Once the previous process finishes, the current ``<TC2_WORKSPACE>`` should have the following structure:
 * build files are stored in ``<TC2_WORKSPACE>/output/tmp_build/``;
 * final images will be placed in ``<TC2_WORKSPACE>/output/deploy/``.

The ``build-all.sh`` script will build all the components, but each component has its own script, allowing it to be built, cleaned and deployed separately.
All scripts support the ``build``, ``clean``, ``deploy``, ``patch`` commands. ``build-all.sh`` also supports ``all``, which performs a clean followed by a rebuild of all the stack.

The platform and filesystem used should be defined as described previously, but they can also be specified as the following example:
```bash
./run_docker.sh ./build-all.sh -p $PLATFORM -f $FILESYSTEM -t $TC_TARGET_FLAVOR -g $TC_GPU build
```

## Build Components and its dependencies
-------------------------------------

A new dependency to a component can be added in the form of `$component=$dependency` in `dependencies.txt` file

To build a component and rebuild those components that depend on it
```bash
./run_docker.sh ./$filename build with_reqs
```

## Running the software on FVP
---------------------------
For detailed information on how to obtain FVP and run the software on FVP, please consult the user guide documentation.

## Sanity tests
------------
For detailed information on which sanity tests are provided with the TC software stack, how to run them and to check examples of the expected test output, please consult the user guide documentation.


