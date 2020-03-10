FROM centos:6
SHELL ["/bin/bash", "-c"]
RUN yum update -y
RUN yum install -y make \
                   git \
				   m4 \
				   wget \
				   unzip \
				   bzip2 \
				   xz \
				   patch \
				   python \
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
				   gettext

ENV NG_URL=https://raw.githubusercontent.com/dutor/nebula-gears/master/install
ENV OSS_UTIL_URL=http://gosspublic.alicdn.com/ossutil/1.6.10/ossutil64
ENV PACKAGE_DIR=/usr/src/nebula-package
RUN curl -s ${NG_URL} | bash

RUN mkdir -p ${PACKAGE_DIR}
WORKDIR ${PACKAGE_DIR}

COPY build-gcc.sh ${PACKAGE_DIR}/build-gcc.sh
RUN chmod +x ${PACKAGE_DIR}/build-gcc.sh

COPY oss-upload.sh ${PACKAGE_DIR}/oss-upload.sh
RUN chmod +x ${PACKAGE_DIR}/oss-upload.sh

RUN wget -q -O /usr/bin/ossutil64 ${OSS_UTIL_URL}
RUN chmod +x /usr/bin/ossutil64
