.. _docs/totalcompute/tc2/change-log:

Change Log
==========

.. contents::

This document contains a summary of the new features, changes and
fixes in each release of TC2 software stack.


Version TC2-2023.10.04-rc0
--------------------------

Features added
~~~~~~~~~~~~~~
- GPU and DPU support for S1 and S2 translation squashed with SMMU-700;


Version TC2-2023.08.15
----------------------

Features added
~~~~~~~~~~~~~~
- Added support for TensorFlow Lite Machine Learning;
- Extended Docker build support to Debian TC build variant;
- Added support for the following Cortex A720/Cortex A520/Cortex X4 CPU architectural features: AFP, ECV and WFxt;
- Enabled support for Maximum Power Mitigation Mechanism (MPMM);
- Added support for GPU DVFS/Idle power states;
- GPU hardware rendering based on DDK source code compilation and pre-built binaries for Android;


Version TC2-2023.04.21
----------------------

Features added
~~~~~~~~~~~~~~
- Added support for EAS;
- Added support for MPAM;
- Added support for Mali-G720 GPU;
- Added support for Android Hardware Rendering.

Changes
~~~~~~~
- Updated to Android 13;
- GPU and DPU are using S1 translation with SMMU-600.


Version TC2-2022.12.07
----------------------

Features added
~~~~~~~~~~~~~~
- Added support for MTE3/EPAN;
- Added support for Firmware Update;
- Enabled VHE support in Hafnium to support S-EL0 partitions;
- Enabled S2 translation for GPU and DPU using SMMU-700;
- Enabled protected nVHE support for pKVM hypervisor.


Version TC2-2022.08.12
----------------------

Features added
~~~~~~~~~~~~~~
- Hardware Root of Trust;
- Updated Android to AOSP master;
- Microdroid based pVM support in Android.


--------------

*Copyright (c) 2022-2023, Arm Limited. All rights reserved.*
