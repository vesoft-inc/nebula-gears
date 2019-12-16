install(
    FILES
        syscheck
        core-execname
        core-bt
        core-bt-batch
        core-save-to
        least-libc-version
        pthreads
        psyscall
        system-info
        arch-type
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
