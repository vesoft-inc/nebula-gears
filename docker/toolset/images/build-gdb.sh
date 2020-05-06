#! /usr/bin/env bash

set -e

nebula-gears-update

release="$(lsb_release -si) $(lsb_release -sr)"
if [[ "$release" =~ "CentOS 8" ]]
then
    echo "Skip build GCC for Centos 8"
    exit 0
fi

if [[ "$release" =~ "Debian 10" ]]
then
    echo "Skip build GCC for Debian 10"
    exit 0
fi

this_dir=$(dirname $(readlink -f $0))

versions=${BUILD_GDB_VERSIONS:-all}

install-gcc --version=9.2.0
source /opt/vesoft/toolset/gcc/9.2.0/enable

build-gdb --version=$versions


cp -v toolset-build/vesoft-gdb-*.sh /data

[[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh toolset toolset-build/vesoft-gdb-*.sh

