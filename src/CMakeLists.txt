add_executable(elf-size elf-size.cpp)
target_link_options(elf-size PRIVATE -static)
target_link_libraries(elf-size elf z)

add_executable(elf-isa elf-isa.cpp)
target_link_options(elf-isa PRIVATE -static)
target_link_libraries(elf-isa capstone elf)
add_dependencies(elf-isa external_capstone)

install(
    TARGETS
        elf-isa
        elf-size
    DESTINATION
        bin
)
