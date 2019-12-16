add_executable(elf-isa elf-isa.cpp)
target_link_options(elf-isa PRIVATE -static)
target_link_libraries(elf-isa capstone elf)
add_dependencies(elf-isa external_capstone)

install(
    TARGETS
        elf-isa
    DESTINATION
        bin
)
