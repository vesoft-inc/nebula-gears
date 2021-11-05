#! /usr/bin/env bash

set -e

nebula-gears-update

release="$(lsb_release -si) $(lsb_release -sr)"

this_dir="$(cd "$(dirname "$0")" && pwd)"

versions=${BUILD_GCC_VERSIONS:-all}

build-gcc --version=$versions

[[ -d /data ]] && cp -v toolset-build/vesoft-gcc-*.sh /data/

${this_dir}/oss-upload.sh toolset-yee toolset-build/vesoft-gcc-*.sh
