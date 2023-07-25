.. _docs/totalcompute/tc2/release_notes:

Release notes - 2023.04.21
==========================

.. contents::

Release tag
-----------
The manifest tag for this release is ``TC2-2023.04.21``.

Components
----------
The following is a summary of the key software features of the release:
 - BSP build supporting Android, Buildroot and Debian distros;
 - Trusted firmware-A for secure boot;
 - U-Boot bootloader;
 - Hafnium for S-EL2 Secure Partition Manager core;
 - OP-TEE for Trusted Execution Environment (TEE) in Buildroot;
 - Trusted Services (Crypto, Internal Trusted Storage and Firmware Update) in Buildroot;
 - Trusty for Trusted Execution Environment (TEE) with FF-A messaging in Android;
 - System control processor(SCP) firmware for programming the interconnect, power control etc;
 - Runtime Security Subsystem (RSS) firmware for providing HW RoT.

Hardware Features
-----------------
 - Booker aka CoreLink CI-700 with Memory Tagging Unit(MTU) support driver in SCP firmware;
 - GIC Clayton Initialization in Trusted Firmware-A;
 - Mali TTIx GPU;
 - Mali-D71 DPU and virtual encoder support for display in Linux;
 - MHUv2 Driver for SCP and AP communication;
 - UARTs, Timers, Flash, PIK, Clock drivers;
 - PL180 MMC;
 - DynamIQ Shared Unit (DSU) with 8 cores. 1 Cortex X4 + 3 Cortex A720 + 4 Cortex A520 cores configuration;
 - RSS based on Cortex M55;
 - SCP based on Cortex M3.

Software Features
-----------------
 - Buildroot distribution support;
 - Debian 11 (aka Bullseye);
 - Android 13 support;
 - Android Common Kernel 5.15.41;
 - Android Hardware Rendering with Mali TTIx GPU - DDK r40p0_01eac0;
 - Android Software rendering with DRM Hardware Composer offloading composition to Mali D71 DPU;
 - KVM default mode of operation is set to ``protected``, thus effectively enabling pKVM on the system. This is a nVHE based mode with kernel running at EL1;
 - Microdroid based pVM support in Android;
 - GPU and DPU are using S1 translation with SMMU-600;
 - Support for MPAM - https://developer.arm.com/documentation/107768/0100/Arm-Memory-System-Resource-Partitioning-and-Monitoring--MPAM--Extension;
 - Support for EAS - https://community.arm.com/oss-platforms/w/docs/530/energy-aware-scheduling-eas;
 - Trusted Firmware-A v2.8;
 - Hafnium v2.7;
 - OP-TEE 3.20.0;
 - Trusty with FF-A messaging - FF-A v1.0;
 - CI700-PMU enabled for profiling;
 - Support secure boot based on TBBR specification https://developer.arm.com/documentation/den0006/latest
 - System Control Processor (SCP) firmware v2.11;
 - Runtime Security Subsystem (RSS) firmware v1.7.0;
 - Build system based on scripts which improves build times compared to Yocto;
 - U-Boot bootloader v2022.04;
 - Power management features: cpufreq and cpuidle;
 - SCMI (System Control and Management Interface) support;
 - Virtio to mount the android image in the host machine as a storage device in the FVP;
 - Verified u-boot for authenticating fit image (containing kernel + ramdisk) during Buildroot boot;
 - Android Verified Boot (AVB) for authenticating boot and system image during Android boot;
 - Hafnium as Secure Partition Manager (SPM) at S-EL2;
 - OP-TEE as Secure Partition at S-EL1, managed by S-EL2 SPMC (Hafnium);
 - Arm FF-A driver and FF-A Transport support for OP-TEE driver in Android Common Kernel;
 - OP-TEE Support in Buildroot distribution. This includes OP-TEE client and OP-TEE test suite;
 - Trusted Services (Crypto, Internal Trusted Storage and Firmware Update) running at S-EL0;
 - Trusted Services test suite added to Buildroot distribution;
 - Tracing - Added support for ETE and TRBE v1.0 in TF-A, kernel and simpleperf. Traces can be captured with simpleperf. However, to enable tracing, the libete plugin has to be loaded while executing the FVP with ``--plugin <path to plugin>/libete-plugin.so``;
 - Firmware update support.

Platform Support
----------------
 - This software release is tested on TC2 Fast Model platform (FVP) version 11.21.20.

Tools Support
-------------
 - This software release introduces docker support (at the moment supporting only the "image building process").

Known issues or Limitations
---------------------------
 #. At the U-Boot prompt press ``enter`` and type ``boot`` to continue booting else wait
    for ~15 secs for boot to continue automatically. This is because of the time
    difference in CPU frequency and FVP operating frequency;
 #. Ubuntu 22.04 is not supported in this release;
 #. SVE2 (Scalable Vector Extension) feature is not supported with this release.

Support
-------
For support email:  support-arch@arm.com


--------------

*Copyright (c) 2022-2023, Arm Limited. All rights reserved.*
