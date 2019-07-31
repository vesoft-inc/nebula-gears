# vim: ft=gdb
set prompt \001\033[31m\002gdb> \001\033[0m\002
set print asm-demangle
set print pretty
set history save on

python
import os
gdb.execute('set history filename ' + os.environ['HOME'] + '/.gdb_history')
end

define show-vtbl
    dont-repeat
    info vtbl $arg0
end

document show-vtbl
show-vtbl <obj>
Show vtable of the object at <obj>
end

define show-vtbl-at
    dont-repeat
    info vtbl ($arg0 *)$arg1
end

document show-vtbl-at
show-vtbl-at <type_name> <address>
Show vtable of an object of <type_name> located at <address>
end

define show-vtbl-by-type
    dont-repeat
    if $argc == 0
        help show-vtbl-by-type
    end
    if $argc > 2
        help show-vtbl-by-type
    end
    set $__vtbl_addr = (char*)&'vtable for $arg0'
    set $__count = 8
    if $argc == 2
        set $__count = $arg1
    end
    set $__index = 0
    while $__index < $__count
        x/a $__vtbl_addr + $__index * 8
        set $__index = $__index + 1
    end
end

document show-vtbl-by-type
show-vtbl-by-type <type_name> [count]
Show [count] entries of vtable for type <type_name>
end

define show-threads-bt
    dont-repeat
    if $argc > 0
        thread apply all backtrace $arg0
    else
        thread apply all backtrace
    end
end

document show-threads-bt
show-threads-bt [count]
Show the outmost [count] frames for all threads
end

define sed
    dont-repeat
end

define show-bt-on-throw
    dont-repeat
    if $argc > 1
        help show-bt-on-throw
    end
    if $argc == 0
        catch throw
    else
        catch throw $arg0
    end
    commands
        bt
        continue
    end
end

document show-bt-on-throw
show-bt-on-throw [exception]
Show the backtrace if any, or a specified exception gets thrown, then continue.
end

python
import glob
import os
for f in glob.glob(os.environ['HOME'] + '/.gdb/*.py'):
  gdb.execute('source %s' % f)
end
