#! /usr/bin/env bash

set -e

arch=$(uname -m)

nebula-gears-update

release="$(lsb_release -si) $(lsb_release -sr)"

this_dir=$(dirname $(readlink -f $0))

versions=${BUILD_LLVM_VERSIONS:-all}

install-gcc --version=9.2.0

install-cmake
source /opt/vesoft/toolset/cmake/enable

build-llvm --version=$versions


cp -v toolset-build/vesoft-llvm-*.sh /data

[[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh toolset toolset-build/vesoft-llvm-*.sh
