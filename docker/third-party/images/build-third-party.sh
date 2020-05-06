#! /usr/bin/env bash

this_dir=$(dirname $(readlink -f $0))

set -e

nebula-gears-update

git clone --depth=1 https://github.com/vesoft-inc/nebula.git

versions=${USE_GCC_VERSIONS:-7.1.0,7.5.0,8.3.0,9.1.0,9.2.0}
install-gcc --version=$versions

nebula/third-party/install-cmake.sh

export PATH=$PWD/cmake-3.15.5/bin:$PATH

for v in $(echo $versions | tr ',' ' ')
do
    source /opt/vesoft/toolset/gcc/$v/enable
    rm -rf /opt/vesoft/third-party
    build_package=1 disable_cxx11_abi=0 nebula/third-party/build-third-party.sh /opt/vesoft/third-party
    rm -rf /opt/vesoft/third-party
    build_package=1 disable_cxx11_abi=1 nebula/third-party/build-third-party.sh /opt/vesoft/third-party
    source /opt/vesoft/toolset/gcc/$v/disable
done

cp -v third-party/vesoft-third-party-*.sh /data

[[ -n $OSS_ENDPOINT ]] && ${this_dir}/oss-upload.sh third-party third-party/vesoft-third-party-*.sh
