FROM debian:8

ARG BUILD_LLVM_VERSIONS=""
ARG BUILD_GCC_VERSIONS=""

SHELL ["/bin/bash", "-c"]
RUN apt-get update
RUN apt-get install -y make \
                       git \
                       m4 \
                       wget \
                       unzip \
                       curl \
                       xz-utils \
                       liblzma-dev \
                       python-dev \
                       patch \
                       lsb-core \
                       libz-dev \
                       build-essential \
                       libtool \
                       automake \
                       autoconf \
                       autoconf-archive \
                       autotools-dev \
                       bison \
                       flex \
                       gperf \
                       gettext --force-yes
RUN apt-get install -y pxz

ENV NG_URL=https://raw.githubusercontent.com/vesoft-inc/nebula-gears/master/install
ENV OSS_UTIL_URL=http://gosspublic.alicdn.com/ossutil/1.7.0
ENV PACKAGE_DIR=/usr/src
RUN set -o pipefail && curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY . ${PACKAGE_DIR}

RUN chmod +x ${PACKAGE_DIR}/docker/images/build-gcc.sh
RUN chmod +x ${PACKAGE_DIR}/docker/images/build-llvm.sh
RUN chmod +x ${PACKAGE_DIR}/docker/images/oss-upload.sh

RUN [[ $(uname -m) = "aarch64" ]] && ARCH="arm"; wget -q -O /usr/bin/ossutil64 ${OSS_UTIL_URL}/ossutil${ARCH}64
RUN chmod +x /usr/bin/ossutil64

RUN --mount=type=secret,id=ossutilconfig,dst=/root/.ossutilconfig ${PACKAGE_DIR}/docker/images/run.sh
