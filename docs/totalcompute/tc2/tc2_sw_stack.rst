.. _docs/totalcompute/tc2/tc2_sw_stack:

.. section-numbering::
    :suffix: .

Total Compute Platform Software Components
==========================================

.. figure:: tc2_sw_stack.png
   :alt: Total Compute Software Stack

Hardware Root of Trust is enabled in TC2. It bootstraps SCP and AP by loading the below images.

 #. SCP BL1
 #. AP BL1

SCP Firmware
------------
The System Control Processor (SCP) is a compute unit of Total Compute and is responsible for low-level system management. The SCP is a Cortex-M3 processor with a set of dedicated peripherals and interfaces that you can extend.
SCP firmware supports:

 #. Powerup sequence and system start-up
 #. Initial hardware configuration
 #. Clock management
 #. Servicing power state requests from the OS Power Management (OSPM) software

SCP BL1
........
It performs the following functions:

 #. Sets up generic timer, UART console and clocks
 #. Initializes the Coherent Interconnect
 #. Powers ON primary AP CPU
 #. Loads SCP Runtime Firmware

SCP Runtime Firmware
....................
SCP runtime code starts execution after TF-A BL2 has authenticated and copied it from flash.
It performs the following functions:

 #. Responds to SCMI messages via MHUv2 for CPU power control and DVFS
 #. Power Domain management
 #. Clock management

Secure Software
---------------
Secure software/firmware is a trusted software component that runs in the AP secure world. It mainly consists of AP firmware, Secure Partition Manager and Secure Partitions (OP-TEE, Trusted Services).

AP firmware
...........
The AP firmware consists of the code that is required to boot Total Compute platform up the point where the OS execution starts. This firmware performs architecture and platform initialization. It also loads and initializes secure world images like Secure partition manager and Trusted OS.

Trusted Firmware-A (TF-A) BL1
+++++++++++++++++++++++++++++
BL1 performs minimal architectural initialization (like exception vectors, CPU initialization) and Platform initialization. It loads the BL2 image and passes control to it.

Trusted Firmware-A (TF-A) BL2
+++++++++++++++++++++++++++++
BL2 runs at S-EL1 and performs architectural initialization required for subsequent stages of TF-A and normal world software. It configures the TrustZone Controller and carves out memory region in DRAM for secure and non-secure use. BL2 loads below images:

 #. SCP BL2 image
 #. EL3 Runtime Software (BL31 image)
 #. Secure Partition Manager (BL32 image)
 #. Non-Trusted firmware - U-boot (BL33 image)
 #. Secure Partitions images (OP-TEE and Trusted Services)

Trusted Firmware-A (TF-A) BL31
++++++++++++++++++++++++++++++
BL2 loads EL3 Runtime Software (BL31) and BL1 passes control to BL31 at EL3. In Total Compute BL31 runs at trusted SRAM. It provides below mentioned runtime services:

 #. Power State Coordination Interface (PSCI)
 #. Secure Monitor framework
 #. Secure Partition Manager Dispatcher

Secure Partition Manager
........................
Total Compute enables FEAT S-EL2 architectural extension, and it uses Hafnium as Secure Partition Manager Core (SPMC). BL32 option in TF-A is re-purposed to specify the SPMC image. The SPMC component runs at S-EL2 exception level.

Secure Partitions
.................
Software image isolated using SPM is Secure Partition. Total Compute enables OP-TEE and Trusted Services (Crypto, Internal Trusted Storage) as Secure Partitions.

OP-TEE
++++++
OP-TEE Trusted OS is virtualized using Hafnium at S-EL2. OP-TEE OS for Total Compute is built with FFA and SEL2 SPMC support. This enables OP-TEE as a Secure Partition running in an isolated address space managed by Hafnium. The OP-TEE kernel runs at S-EL1 with Trusted applications running at S-EL0.

Trusted Services
++++++++++++++++
Trusted Services like Crypto Service and Internal Trusted Storage runs as S-EL0 Secure Partitions using a Shim layer at S-EL1. These services along with S-EL1 Shim layer are built as a single image. The Shim layer forwards FF-A calls from S-EL0 to S-EL2.

U-Boot
------
TF-A BL31 passes execution control to U-boot bootloader (BL33). U-boot in Total Compute has support for multiple image formats:

 #. FitImage format: this contains the Linux kernel and Buildroot ramdisk which are authenticated and loaded in their respective positions in DRAM and execution is handed off to the kernel.
 #. Android boot image: This contains the Linux kernel and Android ramdisk. If using Android Verified Boot (AVB) boot.img is loaded from MMC to DRAM, authenticated and then execution is handed off to the kernel.

Kernel
------
Linux Kernel in Total Compute contains the subsystem-specific features that demonstrate the capabilities of Total Compute. Apart from default configuration, it enables:

 #. Arm MHUv2 controller driver
 #. Arm FF-A driver
 #. OP-TEE driver with FF-A Transport Support
 #. Arm FF-A user space interface driver
 #. Trusty driver with FF-A Transport Support

Android
-------
Total Compute has support for Android Open-Source Project (AOSP), which contains the Android framework, Native Libraries, Android Runtime and the Hardware Abstraction Layers (HALs) for Android Operating system.
The Total Compute device profile defines the required variables for Android such as partition size and product packages and has support for the below configuration of Android:

 #. Software rendering: This profile has support for Android UI and boots Android to home screen. It uses SwiftShader to achieve this. Swiftshader is a CPU base implementation of the Vulkan graphics API by Google.

