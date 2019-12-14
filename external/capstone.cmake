# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.

set(name external_capstone)
set(build_root ${CMAKE_CURRENT_BINARY_DIR}/external)
ExternalProject_Add(
    ${name}
    GIT_REPOSITORY https://github.com/aquynh/capstone.git
    GIT_TAG next
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    PREFIX ${build_root}/${name}
    TMP_DIR ${build_root}/build-info
    STAMP_DIR ${build_root}/build-info
    DOWNLOAD_DIR ${build_root}/build-info
    SOURCE_DIR ${build_root}/${name}/source
    UPDATE_COMMAND ""
    CMAKE_ARGS
        -DCAPSTONE_X86_SUPPORT=ON
        -DCAPSTONE_ARM_SUPPORT=OFF
        -DCAPSTONE_ARM64_SUPPORT=OFF
        -DCAPSTONE_M680X_SUPPORT=OFF
        -DCAPSTONE_M68K_SUPPORT=OFF
        -DCAPSTONE_MIPS_SUPPORT=OFF
        -DCAPSTONE_MOS65XX_SUPPORT=OFF
        -DCAPSTONE_PPC_SUPPORT=OFF
        -DCAPSTONE_SPARC_SUPPORT=OFF
        -DCAPSTONE_SYSZ_SUPPORT=OFF
        -DCAPSTONE_XCORE_SUPPORT=OFF
        -DCAPSTONE_TMS320C64X_SUPPORT=OFF
        -DCAPSTONE_M680X_SUPPORT=OFF
        -DCAPSTONE_EVM_SUPPORT=OFF
        -DCAPSTONE_BUILD_DIET=OFF
        -DCAPSTONE_X86_REDUCE=OFF
        -DCAPSTONE_BUILD_TESTS=OFF
        -DCAPSTONE_BUILD_STATIC=ON
        -DCAPSTONE_BUILD_SHARED=OFF
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=${build_root}/install
    BUILD_COMMAND make -s
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND make -s install
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND make clean -j
    COMMAND rm -f <STAMP_DIR>/${name}-build
    WORKING_DIRECTORY <SOURCE_DIR>
)

ExternalProject_Add_StepTargets(${name} clean)
