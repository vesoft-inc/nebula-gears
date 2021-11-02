#! /usr/bin/env bash

set -e

if [[ ! -z "${BUILD_GCC_VERSIONS}" ]] && [[ ${BUILD_COMPILER} = "gcc" ]]; then
    ./build-gcc.sh
fi

if [[ ! -z "${BUILD_LLVM_VERSIONS}" ]] && [[ ${BUILD_COMPILER} = "llvm" ]]; then
    ./build-llvm.sh
fi
