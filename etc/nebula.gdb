# vim: ft=gdb
set print asm-demangle
set print pretty
set history save on
set prompt \001\033[31m\002gdb> \001\033[0m\002

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
    if $argc == 0 || $argc > 2
        help show-vtbl-by-type
    else
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
    else
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
end

document show-bt-on-throw
show-bt-on-throw [exception]
Show the backtrace if any, or a specified exception gets thrown, then continue.
end


define decode-varint
    set $__pos = (signed char*)$arg0
    set $__return = (uint64_t)0
    set $__shift = 0
    while *$__pos < 0
        set $__return = $__return | (((uint64_t)*$__pos  & 0x7f) << $__shift)
        set $__shift +=  7
        set $__pos += 1
    end
    set $__return |= (uint64_t)*$__pos << $__shift
end

define p-varint
    if $argc != 1
        help p-varint
    else
        decode-varint $arg0
        printf "hex: 0x%lx, dec: %lu\n", $__return, $__return
    end
end

document p-varint
p-varint <address>
Print the value encoded in a buffer.
end

define decode-zigzag
    set $__uvalue = (uint64_t)$arg0
    set $__return = (int64_t)(($__uvalue >> 1) ^ -($__uvalue & 0x1))
end

define p-zigzag
    if $argc != 1
        help p-zigzag
    else
        decode-zigzag $arg0
        printf "dec: %ld, hex: 0x%lx\n", $__return, $__return
    end
end

document p-zigzag
p-zigzag <value>
end

python
import glob
import os
for f in glob.glob(os.environ['HOME'] + '/.gdb/*.py'):
  gdb.execute('source %s' % f)
end


python


class NebulaPrinter:
    def get_from_unique_ptr(self, ptr):
        return ptr['_M_t']['_M_t']['_M_head_impl']

class StatusPrinter(NebulaPrinter):
    def __init__(self, value):
        self.value = value

    def to_string(self):
        base_ptr = self.get_from_unique_ptr(self.value['state_'])
        if base_ptr == 0:
            return "OK"
        size_ptr = base_ptr.cast(gdb.lookup_type('uint16_t').pointer())
        code_ptr = (base_ptr + 2).cast(gdb.lookup_type('nebula::Status::Code').pointer())
        msg_ptr = (base_ptr + 4).cast(gdb.lookup_type('char').pointer())
        result = "Status = {\n  code = %s,\n  msg  = \"%s\"\n}" % (str(code_ptr.dereference()), msg_ptr.string(length = size_ptr.dereference()))
        return result;

class StatusOrPrinter(NebulaPrinter):
    def __init__(self, value):
        self.value = value

    def to_string(self):
        state = self.value['state_']
        if state == 0:
            return "void"
        if state == 1:
            return str(self.value['variant_']['status_'])
        if state == 2:
            return str(self.value['variant_']['value_'])

class HostAddrPrinter:
    def __init__(self, value):
        self.value = value

    def to_string(self):
        return str(self.value.type)

def build_nebula_printers():
    pp = gdb.printing.RegexpCollectionPrettyPrinter("nebula-printers")
    pp.add_printer("Status", "^nebula::Status$", StatusPrinter)
    pp.add_printer("StatusOr", "^nebula::StatusOr<.*>$", StatusOrPrinter)
    pp.add_printer("HostAddr", "struct std::pair<int, int>", HostAddrPrinter)
    return pp

gdb.printing.register_pretty_printer(gdb.current_progspace(), build_nebula_printers())


class InfoExecution(gdb.Command):
    def __init__(self):
        super(InfoExecution, self).__init__("info-execution", gdb.COMMAND_DATA)
        self.methods = {
            'executor': self.get_from_executor,
            'ectx': self.get_from_executor,
            'rctx': self.get_from_executor,
        }

    def dispatch(self, key, ptr):
        self.methods[key](ptr)

    def get_from_executor(self, ptr):
        base_ptr = ptr.cast(gdb.lookup_type('nebula::graph::Executor').pointer())
        rctx_ptr = base_ptr.dereference()['ectx_'].dereference()['rctx_'].cast(gdb.lookup_type('nebula::graph::RequestContext<nebula::graph::cpp2::ExecutionResponse>').pointer())
        print(str(rctx_ptr.dereference()['query_']))

    def get_key(self, ptr):
        if str(ptr.type).find('Executor') != -1:
            return "executor"
        elif str(ptr.type).find('ExecutionContext') != -1:
            return "ectx"
        elif str(ptr.type).find('RequestContext') != -1:
            return "rctx"
        else:
            return None

    def invoke(self, arg, from_tty):
        if not arg:
            arg = 'this'
        ptr = gdb.parse_and_eval(arg)
        key = self.get_key(ptr)
        self.dispatch(key, ptr)

InfoExecution()

class PrintIPv4(gdb.Command):
    """print-ipv4 <int|pair>"""
    def __init__(self):
        super(PrintIPv4, self).__init__("print-ipv4", gdb.COMMAND_USER)

    def int_to_ipv4(self, value):
        ivalue = int(value)
        b1 = ivalue & 0xFF
        b2 = (ivalue >> 8) & 0xFF
        b3 = (ivalue >> 16) & 0xFF
        b4 = (ivalue >> 24) & 0xFF
        return "%d.%d.%d.%d" % (b4, b3, b2, b1)

    def pair_to_addr(self, value):
        ipv4 = self.int_to_ipv4(value['first'])
        port = int(value['second'])
        return "%s:%d" % (ipv4, port)

    def invoke(self, arg, from_tty):
        if not arg:
            gdb.execute('help print-ipv4')
            return
        value = gdb.parse_and_eval(arg)
        type_str = str(value.type)
        print(type_str)
        if type_str == "int":
            print(self.int_to_ipv4(value))
        elif type_str == 'std::pair<int, int>':
            print(self.pair_to_addr(value))

PrintIPv4()

class TestCommand(gdb.Command):
    def __init__(self):
        super(TestCommand, self).__init__("test-command", gdb.COMMAND_USER)

    def invoke(self, arg, from_tty):
        value = gdb.parse_and_eval(arg)
        i = 0
        type = value.type.template_argument(i)
        while type:
            print(str(type.tag))
            i += 1
            type = value.type.template_argument(i)

TestCommand()
end
