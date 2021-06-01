install(
    FILES
        mem-available
        physical-cores
        build-gcc
        install-gcc
        build-llvm
        install-llvm
        build-gdb
        install-gdb
        build-cmake
        install-cmake
        cxx-compiler-usability-test
        nebula-gears-update
        nebula-gears-uninstall
        nebula-gears-show-files
    PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
    DESTINATION
        bin
)
