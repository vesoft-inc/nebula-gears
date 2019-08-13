install(
    FILES
        sodag
        syscheck
        core-execname
        core-bt
        core-bt-batch
        core-save-to
        pthreads
    PERMISSIONS
        OWNER_READ OWNER_WRITE OWNER_EXECUTE
        GROUP_READ GROUP_EXECUTE
        WORLD_READ WORLD_EXECUTE
    DESTINATION
        bin
)
