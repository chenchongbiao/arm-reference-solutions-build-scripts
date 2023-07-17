# ML application for Total Compute platforms

<!-- TOC -->
* [ML application for Total Compute platforms](#ml-application-for-total-compute-platforms)
* [Introduction](#introduction)
* [Application](#application)
* [Prerequisites](#prerequisites)
  * [Software utilities](#software-utilities)
  * [Dependencies](#dependencies)
* [Licenses and Trademarks](#licenses-and-trademarks)
  * [Trademarks](#trademarks)
* [Build](#build)
  * [CMake Configuration Options](#cmake-configuration-options)
  * [Environment Variables](#environment-variables)
<!-- TOC -->

# Introduction

This is a CMake wrapper project for building TensorFlow Lite applications for Total Compute targets. By default,
we build the `benchmark_model` application but the developer can build any application exposed by the TensorFlow
Lite's CMake configuration.

Read more about [TensorFlow Lite here](https://github.com/tensorflow/tensorflow/blob/v2.13.0/tensorflow/lite/README.md).

The project will require the user to fetch the required version of TensorFlow Lite from a public git repo and the
CMake wrapper in this project should be pointed to it. It will possibly add or modify some compile definitions to
enable various features suitable for the Total Compute systems.

# Application

We recommend running the model benchmarking application under TensorFlow Lite as this is a good candidate to validate
the machine learning flow for any target platform. This application can consume any neural network model in `.tflite`
format and user specified number of inferences on it to benchmark performance for the whole graph and for individual
operators. Read more about
[Model benchmark tool here](https://github.com/tensorflow/tensorflow/blob/v2.13.0/tensorflow/lite/tools/benchmark/README.md).

# Prerequisites

All internal tests are done using Linux based machines. The build flow might work on other operating systems
but is not guaranteed.

## Software utilities

Requirements for the host machine:

 * `Git`: version 2 or above.
 * `CMake`:see the minimum version at the top of [CMakeLists.txt](./CMakeLists.txt).
 * `make` on `ninja`: `make` version 4 or higher, and `ninja` 1.10 or higher.
 * `GNU toolchain`: specifically, `aarch64-none-linux-gnu` version 12.2 or higher.
   * When building on an `aarch64` host machine, ensure that the native GNU toolchain supports the CPU flags required
     for the Total Compute system you intend to build for.

## Dependencies

 * `TensorFlow` source tree: This can be done by cloning the tensorflow git repository or downloading a source release
   archive. For example:

   ```shell
   mkdir dependencies && pushd dependencies
   git clone --depth 1 --branch v2.13.0 https://github.com/tensorflow/tensorflow.git
   popd
   ```

   OR

   ```shell
   mkdir dependencies && pushd dependencies
   wget https://github.com/tensorflow/tensorflow/archive/refs/tags/v2.13.0.tar.gz -O tensorflow.tgz --show-progress
   tar xvf tensorflow.tgz
   popd
   ```

# Licenses and Trademarks

This component is licensed under BSD-3 clause in compliance with the rest of this repository.
The primary component downloaded by the build is TensorFlow source tree that is available upstream as `Apache 2.0`.
Note that TensorFlow Lite build system might download its own set of dependencies.

## Trademarks

* TensorFlow™, the TensorFlow logo, and any related marks are trademarks of Google Inc.
* Arm® and Cortex® are registered trademarks of Arm® Limited (or its subsidiaries) in the US and/or elsewhere.
* CMake™ is a trademark of Kitware, Inc.

# Build

A default configuration command (assumed to be executed from the root of the repo) is:

```shell
cmake -Bcmake-build-cross
```
assumes cross-compilation for aarch64 target on an amd64 machine. It will try to find the `aarch64-none-linux-gnu`
toolchain in system PATH. To explicitly set the prefix with the full path, the environment variable
`ML_APP_COMPILER_PREFIX` can be used. For example:

```shell
ML_APP_COMPILER_PREFIX=/my/custom/gnu/toolchain/aarch64-none-linux-gnu- cmake -Bcmake-build-cross
```

Both the above commands show the build path for the default `TARGET_PLATFORM` that assumed aarch64 target. To change
this behavior, for native compilation for example, specify the `TARGET_PLATFORM` explicitly.

```shell
cmake -Bcmake-build-native -DTARGET_PLATFORM=host
```

This will skip setting the `TARGET_PLATFORM` to its default value, and subsequently, the `CMAKE_TOOLCHAIN_FILE`. CMake
will locate the system's default compiler and attempt to use it.

The above commands assume that the TensorFlow sources have been downloaded under `dependencies/tensorflow` as
specified under [dependencies](#dependencies) section. To override this default location, use `TENSORFLOW_SRC` to set
the path explicitly. For example,

```shell
cmake -Bcmake-build-cross -DTENSORFLOW_SRC=/my/custom/tensorflow
```

The build directories specified by `-B` flag in the commands above can then be used to build the project. For example:

```shell
cmake --build ./cmake-build-cross -j
```

To build only the benchmark applications and libraries it depends on, specify the target:

```shell
cmake --build ./cmake-build-cross --target=benchmark_model -j
```

Usually, this will be quicker as it does not build all the targets available within the build tree.

## CMake Configuration Options

* `TENSORFLOW_SRC`: Required; should be set to the directory containing TensorFlow sources.
* `TARGET_PLATFORM`: Optional; if unspecified defaults to an aarch64 based target like `TC22`.
* `TFLITE_ENABLE_XNNPACK`: Optional; set to `ON` by default but can be set to `OFF` to disable use of XNNPack.

## Environment Variables

* `ML_APP_COMPILER_PREFIX`: Can be set to the full path and the toolchain prefix. If unset, the toolchain location
  must be in system `PATH`. See example of usage above.
