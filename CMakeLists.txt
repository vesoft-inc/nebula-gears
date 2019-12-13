cmake_minimum_required(VERSION 3.0)
project("nebula-gears" CXX ASM)

include(GNUInstallDirs)

enable_testing()

set(CMAKE_CXX_STANDARD 17)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY bin)

set(CMAKE_EXE_LINKER_FLAGS "-static-libstdc++ -no-pie")

include_directories(${PROJECT_SOURCE_DIR}/src)

add_compile_options(-O2)
add_compile_options(-ggdb3)
add_compile_options(-Wall)
add_compile_options(-Wextra)
add_compile_options(-Wno-class-memaccess)
add_compile_options(-Werror)
add_compile_options(-fdebug-prefix-map=${PROJECT_SOURCE_DIR}/=)

add_subdirectory(etc)
add_subdirectory(scripts)
add_subdirectory(src)
