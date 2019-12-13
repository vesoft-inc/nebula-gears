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
    PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
    DESTINATION
        bin
)
