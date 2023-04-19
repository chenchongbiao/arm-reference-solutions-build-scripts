.. _docs/totalcompute/tc2/user-guide:

User Guide
==========

.. contents::


Notice
------

The Total Compute 2022 (TC2) software stack uses bash scripts to build a Board
Support Package (BSP) and a choice of Buildroot Linux distribution or Android
userspace.

Prerequisites
-------------

These instructions assume that:
 * Your host PC is running a recent Ubuntu Linux (18.04 or 20.04)
 * You are running the provided scripts in a ``bash`` shell environment.

To get the latest repo tool from google, run the following commands:

::

    mkdir -p ~/bin
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    export PATH=~/bin:$PATH

If syncing and building android, the minimum requirements for the host machine can be found at https://source.android.com/setup/build/requirements, These include:
 * At least 250GB of free disk space to check out the code and an extra 150 GB to build it. If you conduct multiple builds, you need additional space.
 * At least 32 GB of available RAM/swap.
 * Git configured properly using "git config" otherwise it may throw error while fetching the code.

To install and allow access to docker
::

    sudo apt install docker.io
    sudo chmod 777 /var/run/docker.sock

NOTE:

To manage Docker as a non-root user
::

    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker

Syncing and building the source code
------------------------------------

There are two distros supported in the TC2 software stack: buildroot (a minimal distro containing busybox) and Android.

Syncing code
############

Create a new folder that will be your workspace, which will henceforth be referred to as ``<tc2_workspace>``
in these instructions.
::

    mkdir <tc2_workspace>
    cd <tc2_workspace>
    export TC2_RELEASE=refs/tags/TC2-2022.12.07

To sync BSP only without Android, run the following repo command.
::

    repo init -u https://gitlab.arm.com/arm-reference-solutions/arm-reference-solutions-manifest -m tc2.xml -b ${TC2_RELEASE} -g bsp
    repo sync -j `nproc` --fetch-submodules

To sync both the BSP and Android, run the following repo command.
::

    repo init -u https://gitlab.arm.com/arm-reference-solutions/arm-reference-solutions-manifest -m tc2.xml -b ${TC2_RELEASE} -g android
    repo sync -j `nproc` --fetch-submodules

The resulting files will have the following structure:
 - build-scripts/: the components build scripts
 - run-scripts/: scripts to run the FVP
 - src/: each component's git repository

Initial Setup
#############

Setup includes two parts:
 1. Setup a Docker image
 2. Setup the environmet to build TC images

Setting up a docker image involves pulling the prebuilt docker image from a docker registry. If that fails, it will build a local docker image.

To setup a docker image, patch the components, install the toolchains and build tools, run:

For buildroot build:
::

    export PLATFORM=tc2
    export FILESYSTEM=buildroot
    ./setup.sh

For an Android build:
::

    export PLATFORM=tc2
    export FILESYSTEM=android-swr
    ./setup.sh

The various tools will be installed in the tools/ directory at the root of the workspace.

To build Android with AVB (Android Verified Boot) enabled, run:
::

    export AVB=true

NOTES:

* If running ``repo sync`` again is needed at some point, then the setup.sh script also needs to be run again, as repo sync can discard the patches.

* Most builds will be done in parallel using all the available cores by default. To change this number, run ``export PARALLELISM=<no of cores>``

Board Support Package build
############################

To build the whole stack, simply run:
::

    ./run_docker.sh ./build-all.sh build

Build files are stored in build-scripts/output/tmp_build/, final images will be placed in build-script/output/deploy/.

More about the build system
###########################

``build-all.sh`` will build all the components, but each component has its own script, allowing it to be built, cleaned and deployed separately.
All scripts support the ``build``, ``clean``, ``deploy``, ``patch`` commands. ``build-all.sh`` also supports ``all``, to clean then rebuild all the stack.

For example, to build, deploy, and clean SCP, run
::

    ./run_docker.sh ./build-scp.sh build
    ./run_docker.sh ./build-scp.sh deploy
    ./run_docker.sh ./build-scp.sh clean

The platform and filesystem used should be defined as described previously, but they can also be specified like so:
::

    ./run_docker.sh ./build-all -p $PLATFORM -f $FILESYSTEM build

Build Components and its dependencies
-------------------------------------

A new dependency to a component can be added in the form of ``$component=$dependency`` in dependencies.txt file

To build a component and rebuild those components that depend on it
::

    ./run_docker.sh ./$filename build with_reqs

Additionally, Android Verified Boot (AVB) can be enabled with the ``-a`` option.
Those options work for all the ``build-*.sh`` scripts.

Android OS build
#################

* tc2_swr  : This supports Android display with swiftshader (software rendering).

The android images can be built with or without authentication enabled using Android Verified Boot(AVB).
AVB build is done in userdebug mode and takes a longer time to boot as the images are verified.

The ``-a`` option does not influence the way the system boots rather it adds an optional sanity check on the prerequisite images.

Android based stack takes considerable time to build, so start the build and go grab a cup of coffee!


Provided components
-------------------

Firmware Components
###################

Trusted Firmware-A
******************

Based on `Trusted Firmware-A <https://trustedfirmware-a.readthedocs.io/en/latest/>`__

+--------+------------------------------------------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-tfa.sh                                                                 |
+--------+------------------------------------------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/deploy/tc2/bl1-tc.bin                                               |
|        | * <tc2_workspace>/build-scripts/output/deploy/tc2/fip-tc.bin                                               |
+--------+------------------------------------------------------------------------------------------------------------+


System Control Processor (SCP)
******************************

Based on `SCP Firmware <https://github.com/ARM-software/SCP-firmware>`__

+--------+------------------------------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-scp.sh                                                     |
+--------+------------------------------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/deploy/tc2/scp_ramfw.bin                                |
|        | * <tc2_workspace>/build-scripts/output/deploy/tc2/scp_romfw.bin                                |
+--------+------------------------------------------------------------------------------------------------+


U-Boot
******

Based on `U-Boot gitlab <https://gitlab.denx.de/u-boot/u-boot>`__

+--------+---------------------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-u-boot.sh                                         |
+--------+---------------------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/deploy/tc2/u-boot.bin                          |
+--------+---------------------------------------------------------------------------------------+


Hafnium
*******

Based on `Hafnium <https://www.trustedfirmware.org/projects/hafnium>`__

+--------+--------------------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-hafnium.sh                                       |
+--------+--------------------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/deploy/tc2/hafnium.bin                        |
+--------+--------------------------------------------------------------------------------------+


OP-TEE
******

Based on `OP-TEE <https://github.com/OP-TEE/optee_os>`__

+--------+------------------------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-optee-os.sh                                          |
+--------+------------------------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/tmp_build/tfa_sp/tee-pager_v2.bin                 |
+--------+------------------------------------------------------------------------------------------+


S-EL0 trusted-services
**********************

Based on `Trusted Services <https://www.trustedfirmware.org/projects/trusted-services/>`__

+--------+-----------------------------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-trusted-services.sh                                       |
+--------+-----------------------------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/tmp_build/tfa_sp/crypto-sp.bin                         |
|        | * <tc2_workspace>/build-scripts/output/tmp_build/tfa_sp/internal-trusted-storage.bin          |
+--------+-----------------------------------------------------------------------------------------------+

Linux
*****

The component responsible for building a 5.15 version of the Android Common kernel (`ACK <https://android.googlesource.com/kernel/common/>`__).

+--------+-----------------------------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-linux.sh                                                  |
+--------+-----------------------------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/deploy/tc2/Image                                       |
+--------+-----------------------------------------------------------------------------------------------+

Trusty
******

Based on `Trusty <https://source.android.com/security/trusty>`__

+--------+---------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-trusty.sh                             |
+--------+---------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/deploy/tc2/lk.bin                  |
+--------+---------------------------------------------------------------------------+

Distributions
#############

Buildroot Linux distro
**********************

The layer is based on the `buildroot <https://github.com/buildroot/buildroot/>`__ Linux distribution.
The provided distribution is based on BusyBox and built using glibc.

+--------+-------------------------------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-buildroot.sh                                                |
+--------+-------------------------------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/deploy/tc2/tc-fitImage.bin                               |
+--------+-------------------------------------------------------------------------------------------------+


Android
*******

+--------+-------------------------------------------------------------------------+
| Script | <tc2_workspace>/build-scripts/build-android.sh                          |
+--------+-------------------------------------------------------------------------+
| Files  | * <tc2_workspace>/build-scripts/output/deploy/tc2/android.img           |
|        | * <tc2_workspace>/build-scripts/output/deploy/tc2/ramdisk_uboot.img     |
|        | * <tc2_workspace>/build-scripts/output/deploy/tc2/system.img            |
|        | * <tc2_workspace>/build-scripts/output/deploy/tc2/userdata.img          |
|        | * <tc2_workspace>/build-scripts/output/deploy/tc2/boot.img (AVB only)   |
|        | * <tc2_workspace>/build-scripts/output/deploy/tc2/vbmeta.img (AVB only) |
+--------+-------------------------------------------------------------------------+


Run scripts
###########

Within the ``<tc2_workspace>/run-scripts/`` there are several convenience functions for testing the software
stack. Usage descriptions for the various scripts are provided in the following sections.


Obtaining the TC2 FVP
---------------------

The TC2 FVP is available to partners for build and run on Linux host environments.
Please contact Arm to have access (support@arm.com).


Running the software on FVP
---------------------------

A Fixed Virtual Platform (FVP) of the TC2 platform must be available to run the included run scripts.

The run-scripts structure is as follows:

::

    run-scripts
    |--tc2
       |--run_model.sh
       |-- ...

Ensure that all dependencies are met by running the FVP: ``./path/to/FVP_TC2``. You should see
the FVP launch, presenting a graphical interface showing information about the current state of the FVP.

The ``run_model.sh`` script in ``<tc2_workspace>/run-scripts/tc2`` will launch the FVP, providing
the previously built images as arguments. Run the ``run_model.sh`` script:

::

    ./run_model.sh
    Incorrect script use, call script as:
    <path_to_run_model.sh> [OPTIONS]
    OPTIONS:
    -m, --model                      path to model
    -d, --distro                     distro version, values supported [buildroot, android-swr]
    -a, --avb                        [OPTIONAL] avb boot, values supported [true, false], DEFAULT: false
    -t, --tap-interface              [OPTIONAL] enable TAP interface
    -e, --extra-model-params	        [OPTIONAL] extra model parameters

Running Buildroot
#################

::

    ./run-scripts/tc2/run_model.sh -m <model binary path> -d buildroot

Running Android
###############

For running android with AVB disabled:
::
 
    ./run-scripts/tc2/run_model.sh -m <model binary path> -d android-swr
 
For running android with AVB enabled:
::

    ./run-scripts/tc2/run_model.sh -m <model binary path> -d android-swr -a true

When the script is run, four terminal instances will be launched:
 * terminal_uart_ap used for U-boot and Linux bootlogs and normal shell prompt
 * terminal_uart1_ap used for TF-A, Hafnium, Trusty and OP-TEE core logs
 * terminal_s0 used for the SCP logs
 * terminal_s1 used by TF-M logs (no output by default)

Once the FVP is running, hardware Root of Trust will verify AP and SCP
images, initialize various crypto services and then handover execution to the
SCP. SCP will bring the AP out of reset. The AP will start booting from its
ROM and then proceed to boot Trusted Firmware-A, Hafnium,
Secure Partitions (OP-TEE, Trusted Services in Buildroot and Trusty in Android) then
U-Boot, and then Linux and Buildroot/Android.

When booting Buildroot, the model will boot Linux and present a login prompt on terminal_uart_ap. Login
using the username ``root``. You may need to hit Enter for the prompt to appear.


Running sanity tests
-----------------------------------

The OP-TEE and Trusted Services are initialized in Buildroot distribution. The functionality of OP-TEE and
core set of trusted services such as Crypto and Internal Trusted Storage can be invoked only on Builroot distribution.

OP-TEE
###############

For OP-TEE, the TEE sanity test suite can be run using command ``xtest`` on terminal_uart_ap.

NOTE:
This test suite will take some time to run all its related tests.


Trusted Services and Client application
########################################

For Trusted Services, run command ``ts-service-test -sg ItsServiceTests -sg PsaCryptoApiTests -sg CryptoServicePackedcTests -sg CryptoServiceProtobufTests -sg CryptoServiceLimitTests -v`` for Service API level tests, and run ``ts-demo`` for the demonstration of the client application.


Trusty
###############

On Android distribution, Trusty provides a Trusted Execution Environment (TEE).
The functionality of Trusty IPC can be tested using command ``tipc-test -t ta2ta-ipc`` with root privilege.
(Once Android boots to prompt, do ``su 0`` for root access)

While booting, GUI window - ``Fast Models - Total Compute 2 DP0`` shows Android logo and on boot completion,
the window will show the Android home screen.

On Android distribution, Virtualization service provides support to run Microdroid based pVM (Protected VM).
For running a demo Microdroid, boot TC FVP with Android distribution. Once the Android is completely up, run below command:

::

    ./run-scripts/tc2/run_microdroid_demo.sh


Kernel Selftest
###############

Tests are located at /usr/bin/selftest on device

To run all the tests in one go, use run_selftest.sh script. Tests can be run individually also.
::

    ./run_kselftest --summary

NOTE:

KSM driver is not a part of the TC2 kernel. Hence, one of the MTE Kselftests will fail for check_ksm_options test.


Debugging on Arm Development Studio
-----------------------------------

Creating a new connection
#########################

#. File->new->model connection
#. Name it and next
#. Add a new model and select CADI interface
#. Select ``Launch and select a specific model``
#. Give TC2 FVP model path and Finish
#. Close

Attach and Debug
################

#. Build the target with debug enabled. ``build-scripts/config`` can be configured to enable debug.
#. Run Buildroot/Android as described above.
#. Select the target created as mentioned in ``Creating a new connection`` and ``connect to target`` from debug control console.
#. After connection, use options in debug control console (highlighted in the below diagram) or keyboard shortcuts to ``step``, ``run`` or ``halt``.
#. To add debug symbols, right click on target -> ``Debug configurations`` and under ``files`` tab add path to ``elf`` files.
#. Debug options such as ``break points``, ``variable watch``, ``memory view`` and so on can be used.

.. figure:: Debug_control_console.png

Switch between SCP and AP
#########################

#. Right click on target and select ``Debug Configurations``
#. Under ``Connection``, select ``Cortex-M3`` for SCP and ``Arm-Hayes_x/Arm-Hunter_x`` for AP core x and then debug

.. figure:: Switch_Cores.png



Firmware Update
---------------
Currently, the firmware update functionality is only supported with the buildroot distro.


Creating Capsule
################

Firmware Update in the total compute platform uses the capsule update mechanism. Hence, the Firmware Image Package (FIP) binary
has to be converted to a capsule. This can be done with ``GenerateCapsule`` which is present in ``BaseTools/BinWrappers/PosixLike``
of the `edk2 project <https://github.com/tianocore/edk2>`__.

::

       GenerateCapsule -e -o efi_capsule --fw-version 1 --lsv 0 --guid 0d5c011f-0776-5b38-8e81-36fbdf6743e2 --update-image-index 0 --verbose fip-tc.bin

| "fip-tc.bin" is the input fip file that has the firmware binaries of the total compute platform
| "efi_capsule" is the name of capsule to be generated
| "0d5c011f-0776-5b38-8e81-36fbdf6743e2" is the image type UUID for the FIP image

Loading Capsule
###############

The capsule generated using the above steps has to be loaded into memory during the execution of the model by providing the below FVP arguments.

::

    --data board.dram=<location of capsule>/efi_capsule@0x2000000


This loads the capsule to be updated at address 0x82000000.

The final command to run the model for buildroot should look like the following:

::

    ./run-scripts/tc2/run_model.sh -m <model binary path> -d buildroot -e "--data board.dram=<location of capsule>/efi_capsule@0x2000000"


Updating Firmware
#################

During the normal boot of the platform, stop at the U-Boot prompt and execute the below commands.

::

    TOTAL_COMPUTE# efidebug capsule update -v 0x82000000

This will update the firmware. After it is completed, reboot the platform using the FVP GUI


*Copyright (c) 2023, Arm Limited. All rights reserved.*
