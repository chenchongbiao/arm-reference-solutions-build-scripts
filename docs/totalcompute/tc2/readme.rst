.. _docs/totalcompute/tc2/readme:

.. section-numbering::
    :suffix: .

Instructions: Obtaining Total Compute software deliverables
-----------------------------------------------------------
 * To build the TC2 software stack please refer to :ref:`user-guide <docs/totalcompute/tc2/user-guide>`
 * For the list of changes and features added please refer to :ref:`change-log <docs/totalcompute/tc2/change-log>`
 * For further details on the latest release and features please refer to :ref:`release_notes <docs/totalcompute/tc2/release_notes>`

TC Software Stack Overview
--------------------------

The TC2 software consists of firmware, kernel and file system components that can run on the associated FVP.
Following are the Software components:

 #. SCP firmware – System initialization, Clock and Power control
 #. AP firmware – Trusted Firmware-A (TF-A)
 #. Secure Partition Manager
 #. Secure Partitions

    * OP-TEE Trusted OS in Buildroot
    * Trusted Services with Shim layer in Buildroot
    * Trusty Trusted OS in Android

 #. U-Boot – loads and verifies the fitImage for buildroot boot, containing kernel and filesystem or boot Image for Android Verified Boot, containing kernel and ramdisk.
 #. Kernel – supports the following hardware features

    * Message Handling Unit
    * PAC/MTE/BTI features

 #. Android

    * Supports PAC/MTE/BTI features

:ref:`Total Compute Platform Software Components <docs/totalcompute/tc2/tc2_sw_stack>`

