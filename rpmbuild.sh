#! /bin/bash

COLOR_BOLD="\033[1m"
COLOR_END="\033[0m"
COLOR_RED="\033[1;31m"
COLOR_GREEN="\033[1;32m"
COLOR_YELLOW="\033[1;33m"

function INFO() {
    echo -e ${COLOR_BOLD}${COLOR_YELLOW}${1}${COLOR_END}
}

function ERROR() {
    echo -e ${COLOR_BOLD}${COLOR_RED}${1}${COLOR_END}
}

function FATAL() {
    echo -e ${COLOR_BOLD}${COLOR_RED}${1}${COLOR_END}
    exit 1
}

RPM_BUILD_ROOT=$(pwd)/build/RPM_BUILD_ROOT
PACKAGE=nebula-gears
VERSION=1.0.1

srclist=(CMakeLists.txt etc scripts src \
         )

tar czf ${PACKAGE}.tgz ${srclist[@]}
[ $? -eq 0 ] || FATAL "Archive source failed"

[ -d $RPM_BUILD_ROOT ] && rm -rf $RPM_BUILD_ROOT
[ -d $RPM_BUILD_ROOT ] && FATAL "Failed to remove $RPM_BUILD_ROOT"

[ -d $RPM_BUILD_ROOT ] || mkdir -p $RPM_BUILD_ROOT
[ -d $RPM_BUILD_ROOT ] || FATAL "Failed to create $RPM_BUILD_ROOT"

[ -d $RPM_BUILD_ROOT/RPMS ] || mkdir -p $RPM_BUILD_ROOT/RPMS
[ -d $RPM_BUILD_ROOT/SRPMS ] || mkdir -p $RPM_BUILD_ROOT/SRPMS
[ -d $RPM_BUILD_ROOT/BUILD ] || mkdir -p $RPM_BUILD_ROOT/BUILD
[ -d $RPM_BUILD_ROOT/SOURCES ] || mkdir -p $RPM_BUILD_ROOT/SOURCES
[ -d $RPM_BUILD_ROOT/SPECS ] || mkdir -p $RPM_BUILD_ROOT/SPECS

mv ${PACKAGE}.tgz $RPM_BUILD_ROOT/SOURCES
[ $? -eq 0 ] || FATAL "Copy ${PACKAGE}.tgz to $RPM_BUILD_ROOT/SOURCES failed"

cat > $RPM_BUILD_ROOT/SPECS/${PACKAGE}.spec <<EOF
%define version $VERSION
%define __os_install_post %{nil}
%define __check_files %{nil}
%define _unpackaged_files_terminate_build 0
%define dist %(/usr/lib/rpm/redhat/dist.sh)
%define _prefix /usr
%define _topdir $RPM_BUILD_ROOT

Name            : ${PACKAGE}
Packager        : $USER
License         : BSD
Vendor          : VEsoft Inc.
Group           : Development/Libraries
BuildArch       : noarch
Prefix          : %{_prefix}
Release         : 1
Provides        : nebula.gdb,pthreads,syscheck,sodag
Source          : %{name}.tgz
Version         : %{version}
Summary         : Gears for Nebula Graph
URL             : https://github.com/dutor/nebula-gears
%description
              Please refer to http://docs.nebula-graph.io for more details.


%debug_package


%prep

%setup -q -c -n %{name}-%{version}

%build
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=\$RPM_BUILD_ROOT%{_prefix} -DCMAKE_INSTALL_SYSCONFDIR=\$RPM_BUILD_ROOT/etc ..
make -j

%install
cd build
make install -j
cd ..
rm -r build

%post

ldconfig

%files
%{_prefix}/bin/*
%{_sysconfdir}/gdbinit.d/*

%clean


%changelog

EOF

[ $? -eq 0 ] || FATAL "Failed to create Specfile $RPM_BUILD_ROOT/SPECS/${PACKAGE}.spec"

cat ./ChangeLog >> $RPM_BUILD_ROOT/SPECS/${PACKAGE}.spec

[ $? -eq 0 ] || FATAL "Failed to add changelog"

rpmbuild --rmspec --macros=/usr/lib/rpm/macros \
         --buildroot=$RPM_BUILD_ROOT -ba $RPM_BUILD_ROOT/SPECS/${PACKAGE}.spec

[ $? -eq 0 ] || FATAL "Failed to build RPM"

INFO "RPM building done."
INFO "Located at $(ls $RPM_BUILD_ROOT/RPMS/x86_64/*.rpm)"
