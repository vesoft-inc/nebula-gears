#! /usr/bin/env bash

this_dir=$(dirname $(readlink -f $0))

set -e

versions=${BUILD_GCC_VERSIONS:-all}

build-gcc --version=$versions


cp -v toolset-build/vesoft-gcc-*.sh /data

[[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh toolset toolset-build/vesoft-gcc-*.sh
