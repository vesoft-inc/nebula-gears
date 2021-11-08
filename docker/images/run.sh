#! /usr/bin/env bash

set -e

this_dir="$(cd "$(dirname "$0")" && pwd)"

if [[ ! -z "${BUILD_GCC_VERSIONS}" ]]; then
    $this_dir/build-gcc.sh
fi

if [[ ! -z "${BUILD_LLVM_VERSIONS}" ]]; then
    $this_dir/build-llvm.sh
fi
