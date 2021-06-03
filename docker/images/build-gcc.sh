#! /usr/bin/env bash

set -e

nebula-gears-update

release="$(lsb_release -si) $(lsb_release -sr)"

this_dir=$(dirname $(readlink -f $0))

versions=${BUILD_GCC_VERSIONS:-all}

build-gcc --version=$versions


cp -v toolset-build/vesoft-gcc-*.sh /data

[[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh toolset toolset-build/vesoft-gcc-*.sh