#! /usr/bin/env bash

set -e

nebula-gears-update

release="$(lsb_release -si) $(lsb_release -sr)"
if [[ "$release" =~ "CentOS 8" ]]
then
    echo "Skip build GCC for Centos 8"
    exit 0
fi

if [[ "$release" =~ "Debian 9" ]]
then
    echo "Skip build GCC for Debian 9"
    exit 0
fi

if [[ "$release" =~ "Debian 10" ]]
then
    echo "Skip build GCC for Debian 10"
    exit 0
fi

this_dir=$(dirname $(readlink -f $0))

versions=${BUILD_GCC_VERSIONS:-all}

build-gcc --version=$versions


cp -v toolset-build/vesoft-gcc-*.sh /data

[[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh toolset toolset-build/vesoft-gcc-*.sh
