.. _docs/totalcompute/tc2/release_notes:

Release notes - 2022.12.07
==========================

.. contents::

Release tag
-----------
The manifest tag for this release is TC2-2022.12.07

Components
----------
The following is a summary of the key software features of the release:
 - BSP build supporting Android and Buildroot distro.
 - Trusted firmware-A for secure boot.
 - System control processor(SCP) firmware for programming the interconnect, doing power control etc.
 - U-Boot bootloader.
 - Hafnium for S-EL2 Secure Partition Manager core.
 - OP-TEE for Trusted Execution Environment (TEE) in Buildroot.
 - Trusted Services (Crypto and Internal Trusted Storage) in Buildroot.
 - Trusty for Trusted Execution Environment (TEE) with FF-A messaging in Android.

Hardware Features
-----------------
 - Booker CI with Memory Tagging Unit(MTU) support driver in SCP firmware.
 - GIC Clayton Initialization in Trusted Firmware-A.
 - Mali-D71 DPU and virtual encoder support for display in Linux.
 - MHUv2 Driver for SCP and AP communication.
 - UARTs, Timers, Flash, PIK, Clock drivers.
 - PL180 MMC.
 - DynamIQ Shared Unit (DSU) with 8 cores. 4 Hunter + 4 Hayes cores configuration.
 - HW Root of Trust based on the TF-M RSS subsystem.

Software Features
-----------------
 - Buildroot distribution support.
 - Android AOSP master support.
 - Android Common Kernel 5.15
 - With Android AOSP master support, the KVM default mode of operation is set to ``protected``, thus effectively enabling pKVM on the system. This is a nVHE based mode with kernel running at EL1.
 - Microdroid based pVM support in Android
 - GPU and DPU using S2 translation with SMMU-700
 - Trusted Firmware-A & Hafnium v2.7
 - OP-TEE 3.18.0
 - Trusty with FF-A messaging
 - CI700-PMU enabled for profiling
 - Support secure boot based on TBBR specification https://developer.arm.com/documentation/den0006/latest
 - System Control Processor (SCP) firmware v2.10
 - Build system based on scripts which improves build times compared to Yocto
 - U-Boot bootloader v2022.04
 - Power management features: cpufreq and cpuidle.
 - SCMI (System Control and Management Interface) support.
 - Verified u-boot for authenticating fit image (containing kernel + ramdisk) during Buildroot boot.
 - Android Verified Boot (AVB) for authenticating boot and system image during Android boot.
 - Software rendering on Android with DRM Hardware Composer offloading composition to Mali D71 DPU.
 - Hafnium as Secure Partition Manager (SPM) at S-EL2.
 - OP-TEE as Secure Partition at S-EL1, managed by S-EL2 SPMC (Hafnium)
 - Arm FF-A driver and FF-A Transport support for OP-TEE driver in Android Common Kernel.
 - OP-TEE Support in Buildroot distribution. This includes OP-TEE client and OP-TEE test suite.
 - Trusted Services (Crypto and Internal Trusted Storage) running at S-EL0.
 - Trusted Services test suite added to Buildroot distribution.
 - Shim Layer at S-EL1 running on top of S-EL2 SPMC (Hafnium) used by Trusted Services running in S-EL0.
 - Tracing - Added support for ETE and TRBE v1.0 in TF-A, kernel and simpleperf. Traces can be captured with simpleperf. However, to enable tracing, the libete plugin has to be loaded while executing the FVP with ``--plugin <path to plugin>/libete-plugin.so``
 - Example implementation of a HW Root of Trust based on the TF-M RSS subsystem. For non-RSS based boot, please refer to the TC0/TC1 boot flows.
 - Firmware update support

Platform Support
----------------
 - The Buildroot configuration of this software release is tested on TC2 Fast Model platform (FVP).
   - Supported Fast model version for this release is 11.19.29

Known issues or Limitations
---------------------------
 #. Android boot has not been tested on the FVP and is not guaranteed to work.
    All validation of Android has been done on internal FPGA platforms.
 #. At the U-Boot prompt press enter and type "boot" to continue booting else wait
    for ~15 secs for boot to continue automatically. This is because of the time
    difference in CPU frequency and FVP operating frequency.
 #. Ubuntu 22.04 is not supported in this release.
 #. SVE2(Scalable Vector Extension) feature is not supported with this release

Support
-------
For support email:  support-arch@arm.com

--------------

*Copyright (c) 2022, Arm Limited. All rights reserved.*
