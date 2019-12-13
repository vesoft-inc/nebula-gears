cmake_minimum_required(VERSION 3.0)
project("nebula-gears" CXX ASM)


set(CMAKE_CXX_STANDARD 14)

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
