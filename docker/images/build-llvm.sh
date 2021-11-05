#! /usr/bin/env bash

set -e

arch=$(uname -m)

nebula-gears-update

release="$(lsb_release -si) $(lsb_release -sr)"

this_dir="$(cd "$(dirname "$0")" && pwd)"

versions=${BUILD_LLVM_VERSIONS:-all}

install-gcc --version=9.2.0

install-cmake
source /opt/vesoft/toolset/cmake/enable

build-llvm --version=$versions

[[ -d /data ]] && cp -v toolset-build/vesoft-llvm-*.sh /data/

${this_dir}/oss-upload.sh toolset-yee toolset-build/vesoft-llvm-*.sh
