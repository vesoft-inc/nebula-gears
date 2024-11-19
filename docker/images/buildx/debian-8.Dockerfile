FROM debian:8

ARG BUILD_LLVM_VERSIONS=""
ARG BUILD_GCC_VERSIONS=""

SHELL ["/bin/bash", "-c"]
RUN echo "deb http://archive.debian.org/debian/ jessie main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security/ jessie/updates main" >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y --force-yes make \
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
                       gettext \
                       texinfo
RUN apt-get install -y --force-yes pxz

ENV NG_URL=https://raw.githubusercontent.com/vesoft-inc/nebula-gears/master/install
ENV PACKAGE_DIR=/usr/src
RUN set -o pipefail && curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY . ${PACKAGE_DIR}

RUN chmod +x ${PACKAGE_DIR}/docker/images/build-gcc.sh
RUN chmod +x ${PACKAGE_DIR}/docker/images/build-llvm.sh
RUN chmod +x ${PACKAGE_DIR}/docker/images/oss-upload.sh
RUN curl https://gosspublic.alicdn.com/ossutil/install.sh | bash

RUN --mount=type=secret,id=ossutilconfig,dst=/root/.ossutilconfig ${PACKAGE_DIR}/docker/images/run.sh
