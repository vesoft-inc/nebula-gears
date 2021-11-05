FROM centos:7

ARG BUILD_LLVM_VERSIONS=""
ARG BUILD_GCC_VERSIONS=""
ARG BUILD_COMPILER=""

SHELL ["/bin/bash", "-c"]
RUN yum update -y
RUN yum install -y make \
                   git \
                   m4 \
                   wget \
                   unzip \
                   bzip2 \
                   xz \
                   xz-devel \
                   patch \
                   python \
                   python-devel \
                   redhat-lsb-core \
                   zlib-devel \
                   gcc \
                   gcc-c++ \
                   libtool \
                   autoconf \
                   automake \
                   bison \
                   flex \
                   gperf \
                   gettext \
                   epel-release

RUN yum install -y pxz || true

ENV NG_URL=https://raw.githubusercontent.com/vesoft-inc/nebula-gears/master/install
ENV OSS_UTIL_URL=http://gosspublic.alicdn.com/ossutil/1.7.0
ENV PACKAGE_DIR=/usr/src
RUN curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY . ${PACKAGE_DIR}

RUN chmod +x ${PACKAGE_DIR}/docker/images/build-gcc.sh
RUN chmod +x ${PACKAGE_DIR}/docker/images/build-llvm.sh
RUN chmod +x ${PACKAGE_DIR}/docker/images/oss-upload.sh

RUN [[ $(uname -u) = "aarch64" ]] && ARCH="arm"; wget -q -O /usr/bin/ossutil64 ${OSS_UTIL_URL}/ossutil${ARCH}64
RUN chmod +x /usr/bin/ossutil64

RUN --mount=type=secret,id=ossutilconfig,target=$HOME/.ossutilconfig ${PACKAGE_DIR}/docker/images/run.sh
