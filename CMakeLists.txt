cmake_minimum_required(VERSION 3.0)
project("nebula-gears" CXX ASM)

set(CMAKE_CXX_STANDARD 14)

set(MAJOR_VERSION 1)
set(MINOR_VERSION 2)
set(PATCH_LEVEL 0)
set(FULL_VERSION ${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_LEVEL})

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY bin)

set(CMAKE_EXE_LINKER_FLAGS "-static-libstdc++ -static-libgcc -no-pie")

include_directories(${CMAKE_BINARY_DIR}/external/install/include)
link_directories(${CMAKE_BINARY_DIR}/external/install/lib)
link_directories(${CMAKE_BINARY_DIR}/external/install/lib64)
include_directories(${PROJECT_SOURCE_DIR}/src)

add_compile_options(-O2)
add_compile_options(-s)
add_compile_options(-Wall)
add_compile_options(-Wextra)
add_compile_options(-Werror)
#add_compile_options(-fdebug-prefix-map=${PROJECT_SOURCE_DIR}/=)

include(GNUInstallDirs)
include(ExternalProject)
include(external/capstone.cmake)

add_subdirectory(etc)
add_subdirectory(scripts)
add_subdirectory(src)

set(package_name nebula-gears-installer)
configure_file(
    ${CMAKE_SOURCE_DIR}/aux/self-extractable.sh.in
    ${CMAKE_BINARY_DIR}/${package_name}-meta.sh
    @ONLY
)

set(stage_dir "${CMAKE_BINARY_DIR}/stage")
set(stage_install_prefix "${stage_dir}/${CMAKE_INSTALL_PREFIX}")
set(share_dir "share/nebula-gears")
set(installed_files_file "installed_files")

add_custom_target(
    package
    COMMAND
        make -s install/strip DESTDIR=${stage_dir}
    COMMAND
        mkdir -p ${stage_install_prefix}/${share_dir}
    COMMAND
        find ${stage_install_prefix} -type f -fprint ${stage_install_prefix}/${share_dir}/${installed_files_file}
    COMMAND
        find ${stage_install_prefix} -type f -fprint ${stage_install_prefix}/${share_dir}/${installed_files_file}
    COMMAND
        sed -i "s#${stage_install_prefix}/##" ${stage_install_prefix}/${share_dir}/${installed_files_file}
    COMMAND
        cp -f ${CMAKE_BINARY_DIR}/${package_name}-meta.sh ${package_name}.sh
    COMMAND
        tar -cJf - -C ${stage_install_prefix} . >> ${CMAKE_BINARY_DIR}/${package_name}.sh
    COMMAND
        chmod +x ${CMAKE_BINARY_DIR}/${package_name}.sh
)
