#! /usr/bin/env bash

this_dir=$(dirname $(readlink -f $0))

set -e

build-gcc --version=all


${this_dir}/oss-upload.sh toolset toolset-build/vesoft-gcc*.sh
