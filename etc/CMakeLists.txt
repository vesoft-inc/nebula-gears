install(
    FILES
        nebula.gdb
    PERMISSIONS
        OWNER_READ OWNER_WRITE
        GROUP_READ
        WORLD_READ
    DESTINATION
        ${CMAKE_INSTALL_SYSCONFDIR}/gdbinit.d/
)
