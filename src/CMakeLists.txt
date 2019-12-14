add_executable(elfis elfis.cpp)
target_link_options(elfis PRIVATE -static)
target_link_libraries(elfis capstone)
add_dependencies(elfis external_capstone)

install(
    TARGETS
        elfis
    DESTINATION
        bin
)
