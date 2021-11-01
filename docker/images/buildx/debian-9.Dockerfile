FROM debian:9

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
ENV OSS_UTIL_URL=http://gosspublic.alicdn.com/ossutil/1.6.10/ossutil64
ENV PACKAGE_DIR=/usr/src
RUN set -o pipefail && curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY build-gcc.sh ${PACKAGE_DIR}/build-gcc.sh
RUN chmod +x ${PACKAGE_DIR}/build-gcc.sh

COPY build-llvm.sh ${PACKAGE_DIR}/build-llvm.sh
RUN chmod +x ${PACKAGE_DIR}/build-llvm.sh

COPY oss-upload.sh ${PACKAGE_DIR}/oss-upload.sh
RUN chmod +x ${PACKAGE_DIR}/oss-upload.sh

RUN wget -q -O /usr/bin/ossutil64 ${OSS_UTIL_URL}
RUN chmod +x /usr/bin/ossutil64

COPY run.sh ${PACKAGE_DIR}/run.sh
RUN --mount=type=secret,id=ossutilconfig ${PACKAGE_DIR}/run.sh
