#! /usr/bin/env bash

this_dir=$(dirname $(readlink -f $0))

set -e

git clone --depth=1 https://github.com/vesoft-inc/nebula.git

install-gcc --version=7.1.0,7.5.0,8.3.0,9.1.0,9.2.0

nebula/third-party/install-cmake.sh

export PATH=$PWD/cmake-3.15.5/bin:$PATH

for v in 7.1.0 7.5.0 8.3.0 9.1.0 9.2.0
do
    echo $v
    source /opt/vesoft/toolset/gcc/$v/enable;
    rm -rf /opt/vesoft/third-party
    build_package=1 disable_cxx11_abi=0 nebula/third-party/build-third-party.sh /opt/vesoft/third-party
    rm -rf /opt/vesoft/third-party
    build_package=1 disable_cxx11_abi=1 nebula/third-party/build-third-party.sh /opt/vesoft/third-party
    source /opt/vesoft/toolset/gcc/$v/disable;
done

${this_dir}/oss-upload.sh third-party third-party/vesoft-third-party-*.sh
