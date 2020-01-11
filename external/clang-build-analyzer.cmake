# Copyright (c) 2019 vesoft inc. All rights reserved.
#
# This source code is licensed under Apache 2.0 License,
# attached with Common Clause Condition 1.0, found in the LICENSES directory.

set(name clang_build_analyzer)
set(build_root ${CMAKE_CURRENT_BINARY_DIR}/external)
ExternalProject_Add(
    ${name}
    GIT_REPOSITORY https://github.com/dutor/ClangBuildAnalyzer.git
    GIT_TAG master
    GIT_SHALLOW TRUE
    GIT_PROGRESS TRUE
    PREFIX ${build_root}/${name}
    TMP_DIR ${build_root}/build-info
    STAMP_DIR ${build_root}/build-info
    DOWNLOAD_DIR ${build_root}/build-info
    SOURCE_DIR ${build_root}/${name}/source
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make -f <SOURCE_DIR>/projects/make/Makefile LDFLAGS=-static
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND install -D -s <SOURCE_DIR>/build/ClangBuildAnalyzer ${build_root}/install/bin/clang-build-analyzer
    LOG_CONFIGURE TRUE
    LOG_BUILD TRUE
    LOG_INSTALL TRUE
)

ExternalProject_Add_Step(${name} clean
    EXCLUDE_FROM_MAIN TRUE
    ALWAYS TRUE
    DEPENDEES configure
    COMMAND make clean
    COMMAND rm -f <STAMP_DIR>/${name}-build
    WORKING_DIRECTORY <SOURCE_DIR>
)

ExternalProject_Add_StepTargets(${name} clean)
