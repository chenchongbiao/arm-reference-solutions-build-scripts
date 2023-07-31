.. _docs/totalcompute/tc2/release_notes:

Release notes - TC2-2023.08.15-rc0
==================================

.. contents::

Release tag
-----------
The manifest tag for this release is ``TC2-2023.08.15-rc0``.

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
 - Runtime Security Subsystem (RSS) firmware for providing HW RoT;
 - TensorFlow Lite Machine Learning.

Hardware Features
-----------------
 - Booker aka CoreLink CI-700 with Memory Tagging Unit(MTU) support driver in SCP firmware;
 - GIC Clayton Initialization in Trusted Firmware-A;
 - Mali-G720 GPU;
 - Mali-D71 DPU and virtual encoder support for display on Linux;
 - MHUv2 Driver for SCP and AP communication;
 - UARTs, Timers, Flash, PIK, Clock drivers;
 - PL180 MMC;
 - DynamIQ Shared Unit (DSU) with 8 cores. 1 Cortex X4 + 3 Cortex A720 + 4 Cortex A520 cores configuration;
 - RSS based on Cortex M55;
 - SCP based on Cortex M3.

Software Features
-----------------
 - Buildroot distribution support;
 - Debian 12 (aka Bookworm);
 - Android 13 support;
 - Android Common Kernel 5.15.41;
 - Android Hardware Rendering with Mali-G720 GPU - DDK r41p0_01eac0 (source code) or prebuilt binaries;
 - Android Software rendering with DRM Hardware Composer offloading composition to Mali D71 DPU;
 - KVM default mode of operation is set to ``protected`` by default, thus effectively enabling pKVM on the system. This is a nVHE based mode with kernel running at EL1;
 - Microdroid based pVM support in Android;
 - GPU and DPU support for S1 and S2 translation squashed with SMMU-700;
 - GPU DVFS/Idle power states support;
 - Support for MPAM (more info available at `link <https://developer.arm.com/documentation/107768/0100/Arm-Memory-System-Resource-Partitioning-and-Monitoring--MPAM--Extension>`__);
 - Support for EAS (more info available at `link <https://community.arm.com/oss-platforms/w/docs/530/energy-aware-scheduling-eas>`__);
 - Trusted Firmware-A v2.9;
 - Hafnium v2.9;
 - OP-TEE 3.22.0;
 - Trusty with FF-A messaging - FF-A v1.0;
 - CI700-PMU enabled for profiling;
 - Support for secure boot based on TBBR specification (more info available at `link <https://developer.arm.com/documentation/den0006/latest>`__);
 - System Control Processor (SCP) firmware v2.12;
 - Runtime Security Subsystem (RSS) firmware v1.8.0;
 - U-Boot bootloader v2023.04;
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
 - Tracing support, based on ETE and TRBE v1.1 in TF-A, kernel and ``simpleperf``. Traces can be captured with ``simpleperf``.
 - Firmware update support.

Platform Support
----------------
 - This software release is tested on TC2 Fast Model platform (FVP) version 11.22.34.

Tools Support
-------------
 - This software release extends docker support to Debian distro (making it supported to all TC build variants).

Known issues or Limitations
---------------------------
 #. To avoid the waiting time experienced during U-Boot boot time, the user may interrupt the auto-boot process when presented with the message ``Hit any key to stop autoboot: X`` by pressing the ``ENTER`` key and, on the presented command prompt, type ``boot`` followed by ``ENTER`` key to confirm command to immediately boot the distro kernel image. Although the configured delay is shown as 1-3 seconds, it will take considerably more time to boot (approximately 15 seconds) due to the time difference in the CPU frequency and the FVP operating frequency;
 #. Ubuntu 22.04 is not supported in this release;
 #. SVE2 (Scalable Vector Extension) feature is not supported with this release;
 #. For Android builds which do use the TAP network interface, the default browser available in Android (``webview_shell``) is not able to open HTTPS urls. Interested users can attempt to circumvent this limitation by getting the ARM64 specific APK package for other browsers (e.g. Mozilla Firefox), install it using ADB, and use it to browse HTTPS urls;
 #. Debian build with hardware rendering support will show a kernel warning dump during boot, similar to the following excerpt:

	::

	[   21.935767][  T409] mali 2d000000.gpu: Loading Mali firmware 0x3060000
	[   21.947390][  T409] mali 2d000000.gpu: Protected memory allocator not found, Firmware protected mode entry will not be supported
	[   21.952059][  T409] mali 2d000000.gpu: Mali firmware git_sha: e212cd7645850aa3372045fdf48633159bc53c23
	[   22.109481][   T65] ------------[ cut here ]------------
	[   22.109487][   T65] WARNING: CPU: 4 PID: 65 at /XXXX/XXXXXXXX/tc2-dev-debian/src/debian/mali/product/kernel/drivers/gpu/arm/midgard/platform/devicetree/mali_kbase_runtime_pm.c:65 pm_callback_power_off+0xc8/0x1b0 [mali_kbase]
	[   22.109632][   T65] Modules linked in: mali_kbase(OE)
	[   22.109640][   T65] CPU: 4 PID: 65 Comm: kworker/4:1 Tainted: G S         OE     5.15.41-gdcfc9242ce83 #1
	[   22.109649][   T65] Hardware name: arm,tc (DT)
	[   22.109654][   T65] Workqueue: pm pm_runtime_work
	[   22.109661][   T65] pstate: 00400005 (nzcv daif +PAN -UAO -TCO -DIT -SSBS BTYPE=--)
	[   22.109670][   T65] pc : pm_callback_power_off+0xc8/0x1b0 [mali_kbase]
	[   22.109807][   T65] lr : pm_callback_power_off+0xc0/0x1b0 [mali_kbase]
	[   22.109943][   T65] sp : ffff80000aa0bb70
	[   22.109946][   T65] x29: ffff80000aa0bb70 x28: f1ff008000f61300 x27: 0000000000000000
	[   22.109958][   T65] x26: 00000000fffffef7 x25: 0000000525808386 x24: 0000000000000000
	[   22.109968][   T65] x23: 0000000000000000 x22: f7ff008007f18780 x21: fbff008003a48000
	[   22.109980][   T65] x20: 0000000000000000 x19: fbff008003a48000 x18: 0000000000000000
	[   22.109991][   T65] x17: 0000000000000000 x16: 0000000000000000 x15: 000000000000020f
	[   22.110002][   T65] x14: 0000000000000001 x13: 0000000000000000 x12: 0000000000000001
	[   22.110012][   T65] x11: 0000000000000040 x10: ffff80000a378100 x9 : ffff80000a3780f8
	[   22.110024][   T65] x8 : f5ff0080004014f8 x7 : 0000000000000000 x6 : f6ff0080014eb600
	[   22.110034][   T65] x5 : f6ff0080014eb600 x4 : 0000000000000000 x3 : f6ff0080014eb600
	[   22.110045][   T65] x2 : 0000000000000000 x1 : 0000000000000000 x0 : 0000000000000001
	[   22.110055][   T65] Call trace:
	[   22.110060][   T65]  pm_callback_power_off+0xc8/0x1b0 [mali_kbase]
	[   22.110195][   T65]  kbase_pm_clock_off+0xf8/0x1f0 [mali_kbase]
	[   22.110332][   T65]  kbase_pm_handle_runtime_suspend+0x114/0x2fc [mali_kbase]
	[   22.110468][   T65]  kbase_device_runtime_suspend+0x3c/0x11c [mali_kbase]
	[   22.110605][   T65]  pm_generic_runtime_suspend+0x30/0x50
	[   22.110613][   T65]  genpd_runtime_suspend+0xa0/0x250
	[   22.110621][   T65]  __rpm_callback+0x48/0x1b0
	[   22.110627][   T65]  rpm_callback+0x6c/0x80
	[   22.110633][   T65]  rpm_suspend+0x10c/0x61c
	[   22.110640][   T65]  pm_runtime_work+0xc4/0xd0
	[   22.110647][   T65]  process_one_work+0x1c8/0x460
	[   22.110654][   T65]  worker_thread+0x6c/0x420
	[   22.110661][   T65]  kthread+0x14c/0x160
	[   22.110666][   T65]  ret_from_fork+0x10/0x20
	[   22.110674][   T65] ---[ end trace 519c39252536b616 ]---


Support
-------
For support email:  support-arch@arm.com.


--------------

*Copyright (c) 2022-2023, Arm Limited. All rights reserved.*
