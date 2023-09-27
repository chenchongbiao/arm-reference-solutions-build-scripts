.. _docs/totalcompute/tc2/readme:


Instructions: Obtaining Total Compute software deliverables
-----------------------------------------------------------
 * To build the TC2 software stack, please refer to the :ref:`user guide <docs/totalcompute/tc2/user-guide>`;
 * For the list of changes and features added, please refer to the :ref:`changelog <docs/totalcompute/tc2/change-log>`;
 * For further details on the latest release and features, please refer to the :ref:`release notes <docs/totalcompute/tc2/release_notes>`;
 * To get detailed information on the system architecture and each of its components, please refer to the |arm_tc22_reference_design_sdc_link|.

.. |arm_tc22_reference_design_sdc_link| raw:: html

   <a href="https://developer.arm.com/documentation/108028/0000/?lang=en" target="_blank">Arm Total Compute 2022 Reference Design Software Developer Guide</a>

TC Software Stack Overview
--------------------------

The TC2 software consists of firmware, kernel and file system components that can run on the associated FVP.

Following is presented the high-level list of the software components:
 #. SCP firmware – responsible for system initialization, clock and power control;
 #. RSS firmware – provides Hardware Root of Trust;
 #. AP firmware – Trusted Firmware-A (TF-A);
 #. Secure Partition Manager - Hafnium;
 #. Secure Partitions:

    * OP-TEE Trusted OS in Buildroot;
    * Trusted Services in Buildroot;
    * Trusty Trusted OS in Android;

 #. U-Boot – loads and verifies the fitImage for buildroot boot, containing kernel and filesystem or boot Image for Android Verified Boot, containing kernel and ramdisk;
 #. Kernel – supports the following hardware features:

    * Message Handling Unit;
    * PAC/MTE/BTI features;

 #. Android;

    * Supports PAC/MTE/BTI features;

 #. Buildroot;

 #. Debian;
 
 #. TensorFlow Lite Machine Learning;
 

For more information on each of the stack components, please refer to the :ref:`Total Compute Platform Software Components <docs/totalcompute/tc2/tc2_sw_stack>` section.


--------------

*Copyright (c) 2022-2023, Arm Limited. All rights reserved.*
