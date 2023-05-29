Build scripts for Total Compute stack
=====================================

This README is simply a quick-start guide on the build scripts themselves. For more
information on how to obtain and run the Total Compute stack, please refer to
the user guide.

Prerequisites
-------------
Install and allow access to docker
```bash
sudo apt install docker.io
sudo chmod 777 /var/run/docker.sock
```

Setup
-----
Setup includes two parts:
1. Pull/Build a Docker image from Container registry
2. Setup the environmet to build TC images

To pull/build a docker image, patch the components and install the toolchains and build tools, run:

For the Buildroot build:
```bash
export PLATFORM=tc2
export FILESYSTEM=buildroot
./setup.sh
```

For the Android build with hardware rendering:
```bash
export PLATFORM=tc2
export FILESYSTEM=android-fvp
export TC_GPU=true
export TC_TARGET_FLAVOR=fvp
export GPU_DDK_REPO=<PATH TO GPU DDK SOURCE CODE>
export GPU_DDK_VERSION=r40p0_01eac0
export LM_LICENSE_FILE=<LICENSE FILE>
export ARM_PRODUCT_DEF=<PATH TO ELMAP FILE IN ARMCLANG>
export ARMLMD_LICENSE_FILE=<LICENSE FILE>
export ARMCLANG_TOOL=<PATH TO ARMCLANG TOOLCHAIN>
./setup.sh
```

For the Android build with software rendering:
```bash
export PLATFORM=tc2
export TC_GPU=false
export TC_TARGET_FLAVOR=fvp
export FILESYSTEM=android-fvp
./setup.sh
```

The various tools will be installed in the ``tools/`` directory at the root of the workspace.

To build Android with Android Verified Boot (AVB) enabled, run the following command to enable the corresponding flag in addition to any of the two previous Android command variants (please note that this needs to be run before running `./setup.sh`):
```bash
export AVB=true
```

Build options
-------------
**Android OS build**

 * tc2_fvp with `TC_GPU=false` : this supports Android display with swiftshader (software rendering);

 * tc2_fvp with `TC_GPU=true` : this supports Android display with Mali GPU (hardware rendering). GPU DDK source code is available only to licensee partners (please contact support@arm.com).

The Android images can be built with or without authentication enabled using Android Verified Boot (AVB) through the use of the `-a` option. AVB build is done in userdebug mode and takes a longer time to boot as the images are verified. This option does not influence the way the system boots, rather it adds an optional sanity check on the prerequisite images.

Android based stack takes considerable time to build, so start the build and go grab a cup of coffee!

Build the stack
---------------

To build the whole TC2 software stack, simply run:
```bash
./run_docker.sh ./build-all.sh build
```
Once the previous process finishes, the current ``<TC2_WORKSPACE>`` should have the following structure:
 * build files are stored in ``<TC2_WORKSPACE>/build-scripts/output/tmp_build/``;
 * final images will be placed in ``<TC2_WORKSPACE>/build-script/output/deploy/``.

The ``build-all.sh`` script will build all the components, but each component has its own script, allowing it to be built, cleaned and deployed separately.
All scripts support the ``build``, ``clean``, ``deploy``, ``patch`` commands. ``build-all.sh`` also supports ``all``, which performs a clean followed by a rebuild of all the stack.

The platform and filesystem used should be defined as described previously, but they can also be specified as the following example:
```bash
./run_docker.sh ./build-all.sh -p $PLATFORM -f $FILESYSTEM -t $TC_TARGET_FLAVOR -g $TC_GPU build
```

Build Components and its dependencies
-------------------------------------

A new dependency to a component can be added in the form of `$component=$dependency` in `dependencies.txt` file

To build a component and rebuild those components that depend on it
```bash
./run_docker.sh ./$filename build with_reqs
```

Running the software on FVP
---------------------------
For detailed information on how to obtain FVP and run the software on FVP, please consult the user guide documentation.

Sanity tests
------------
For detailed information on which sanity tests are provided with the TC software stack, how to run them and to check examples of the expected test output, please consult the user guide documentation.


