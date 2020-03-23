#! /usr/bin/env bash

set -e

release="$(lsb_release -si) $(lsb_release -sr)"
if [[ "$release" =~ "Debian 7" ]]
then
    echo "Skip build LLVM in Debian 7"
    exit 0
fi

this_dir=$(dirname $(readlink -f $0))

if [[ "$release" =~ "CentOS 6" ]]
then
    source /opt/rh/python27/enable
fi

versions=${BUILD_LLVM_VERSIONS:-all}

install-gcc --version=9.2.0

bash -s < <(curl -s https://raw.githubusercontent.com/vesoft-inc/nebula/master/third-party/install-cmake.sh)

source cmake-3.15.5/bin/enable-cmake.sh

build-llvm --version=$versions


cp -v toolset-build/vesoft-llvm-*.sh /data

[[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh toolset toolset-build/vesoft-llvm-*.sh
