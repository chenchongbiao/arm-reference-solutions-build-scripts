.. _docs/totalcompute/tc2/troubleshooting:

Troubleshooting: common problems and solutions
==============================================

This section provides a list of potential solutions to the most common problems experienced by developers and related with the host development environment.
This list is not intended to be an exhaustive list, especially due to the unpredictability and nature of some problems.
The developer is, therefore, strongly encouraged to read and search for more information regarding the problem and any additional solutions (covered or not in this document).


.. contents::

.. _docs/totalcompute/tc2/docker:


Docker
------

Error message: ``Cannot Connect to a Docker Daemon``
####################################################
**Solution:** Ensure docker service is running, correct permissions and user group membership are properly configured (please refer to :ref:`User Guide - prerequisites <docs/totalcompute/tc2/user-guide_prerequisites>` document section).

Error message: ``transport: dial unix /var/run/docker/containerd/docker-containerd.sock: connect: connection refused``
######################################################################################################################
**Solution:** Restart docker service running following command: ``sudo systemctl restart docker``.


--------------

*Copyright (c) 2022-2023, Arm Limited. All rights reserved.*
