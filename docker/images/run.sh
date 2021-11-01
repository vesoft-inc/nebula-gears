#! /usr/bin/env bash

set -e

[[ ! -z "${BUILD_GCC_VERSIONS}" ]] && ./build-gcc.sh
[[ ! -z "${BUILD_LLVM_VERSIONS}" ]] && ./build-llvm.sh
