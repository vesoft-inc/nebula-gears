add_executable(elfis elfis.cpp)
target_link_options(elfis PRIVATE -static)
target_link_libraries(elfis capstone)
