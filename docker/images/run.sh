#! /usr/bin/env bash

set -e

this_dir="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -z "${BUILD_GCC_VERSIONS}" ]] && [[ ${BUILD_COMPILER} = "gcc" ]]; then
    $this_dir/build-gcc.sh
fi

if [[ ! -z "${BUILD_LLVM_VERSIONS}" ]] && [[ ${BUILD_COMPILER} = "llvm" ]]; then
    $this_dir/build-llvm.sh
fi
