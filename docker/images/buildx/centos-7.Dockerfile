FROM centos:7

ARG BUILD_LLVM_VERSIONS=""
ARG BUILD_GCC_VERSIONS=""

SHELL ["/bin/bash", "-c"]
RUN sed -i 's/^mirrorlist=/#mirrorlist=/g' /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i "s|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-Base.repo && \
    yum install -y epel-release && yum update -y && \
    yum install -y make \
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
                   epel-release \
                   texinfo \
                && yum clean all \
                && rm -rf /var/cache/yum
RUN yum install -y pxz || true

ENV NG_URL=https://raw.githubusercontent.com/vesoft-inc/nebula-gears/master/install
ENV PACKAGE_DIR=/usr/src
RUN curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY . ${PACKAGE_DIR}

RUN chmod +x ${PACKAGE_DIR}/docker/images/build-gcc.sh
RUN chmod +x ${PACKAGE_DIR}/docker/images/build-llvm.sh
RUN chmod +x ${PACKAGE_DIR}/docker/images/oss-upload.sh
RUN curl https://gosspublic.alicdn.com/ossutil/install.sh | bash


RUN --mount=type=secret,id=ossutilconfig,dst=/root/.ossutilconfig ${PACKAGE_DIR}/docker/images/run.sh
