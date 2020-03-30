install(
    FILES
        core-execname
        core-bt
        core-bt-batch
        least-libc-version
        pthreads
        psyscall
        package-type
        libc-version
        mem-total
        mem-free
        mem-available
        physical-cores
        hyper-threads
        distro-name
        distro-fullname
        distro-version
        build-gcc
        install-gcc
        build-llvm
        install-llvm
        build-gdb
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
