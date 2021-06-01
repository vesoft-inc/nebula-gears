#! /usr/bin/env bash

set -e

arch=$(uname -m)

nebula-gears-update

release="$(lsb_release -si) $(lsb_release -sr)"

this_dir=$(dirname $(readlink -f $0))

versions=${BUILD_LLVM_VERSIONS:-all}

install-gcc --version=9.2.0


if [[ $arch = 'x86_64' ]]
then
    bash -s < <(curl -s https://raw.githubusercontent.com/vesoft-inc/nebula/master/third-party/install-cmake.sh)
    export PATH=$PWD/cmake-3.15.5/bin:$PATH
else
    wget https://oss-cdn.nebula-graph.com.cn/toolset/vesoft-cmake-3.15.7-aarch64-glibc-2.17.sh
    bash vesoft-cmake-3.15.7-aarch64-glibc-2.17.sh
    source /opt/vesoft/toolset/cmake/enable
fi

build-llvm --version=$versions


cp -v toolset-build/vesoft-llvm-*.sh /data

[[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh toolset toolset-build/vesoft-llvm-*.sh
