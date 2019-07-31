nebula_add_executable(demo demo.cpp)
nebula_add_executable(
    pthreads
    pthreads.cpp
    $<TARGET_OBJECTS:utils>
)

install(
    TARGETS
        demo
        pthreads
    DESTINATION
        bin
)
