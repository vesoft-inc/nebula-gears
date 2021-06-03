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
    def deref_from_unique_ptr(self, ptr):
        pointer = self.get_from_unique_ptr(ptr)
        return pointer.dereference()

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

class NullPrinter(NebulaPrinter):
    def __init__(self, value):
        self.value = value

    def to_string(self):
        if self.value == 0:
            return "kNullValue"
        if self.value == 1:
            return "kNullNaN"
        if self.value == 2:
            return "kNullBadData"
        if self.value == 3:
            return "kNullBadType"
        if self.value == 4:
            return "kNullOverflow"
        if self.value == 5:
            return "kNullUnknownProp"
        if self.value == 6:
            return "kNullDivByZero"
        if self.value == 7:
            return "kNullOutOfRange"
        return "unknown"

class DatePrinter(NebulaPrinter):
    def __init__(self, value):
        self.value = value

    def to_string(self):
        v = self.value
        return "%04d-%02d-%02d" % (v['year'], v['month'], v['day'])

class TimePrinter(NebulaPrinter):
    def __init__(self, value):
        self.value = value

    def to_string(self):
        v = self.value
        return "%02d:%02d:%02d.%06d" % (v['hour'], v['minute'], v['sec'], v['microsec'])

class DateTimePrinter(NebulaPrinter):
    def __init__(self, value):
        self.value = value

    def to_string(self):
        v = self.value
        return "%04d-%02d-%02d %02d:%02d:%02d.%06d" % (v['year'], v['month'], v['day'], v['hour'], v['minute'], v['sec'], v['microsec'])

class ValuePrinter(NebulaPrinter):
    def __init__(self, value):
        self.value = value

    def to_string(self):
        type = self.value['type_']
        if type == 1:
            return "kEmpty"
        if type == (1<<1):
            return str(self.value['value_']['bVal'])
        if type == (1<<2):
            return str(self.value['value_']['iVal'])
        if type == (1<<3):
            return str(self.value['value_']['fVal'])
        if type == (1<<4):
            return str(self.value['value_']['sVal'])
        if type == (1<<5):
            return str(self.value['value_']['dVal'])
        if type == (1<<6):
            return str(self.value['value_']['tVal'])
        if type == (1<<7):
            return str(self.value['value_']['dtVal'])
        if type == (1<<8):
            return str(self.deref_from_unique_ptr(self.value['value_']['vVal']))
        if type == (1<<9):
            return str(self.deref_from_unique_ptr(self.value['value_']['eVal']))
        if type == (1<<10):
            return str(self.deref_from_unique_ptr(self.value['value_']['pVal']))
        if type == (1<<11):
            return str(self.deref_from_unique_ptr(self.value['value_']['lVal']))
        if type == (1<<12):
            return str(self.deref_from_unique_ptr(self.value['value_']['mVal']))
        if type == (1<<13):
            return str(self.deref_from_unique_ptr(self.value['value_']['uVal']))
        if type == (1<<14):
            return str(self.deref_from_unique_ptr(self.value['value_']['gVal']))
        if type == (1<<63):
            return str(self.value['value_']['nVal'])

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
    pp.add_printer("Value", "^nebula::Value$", ValuePrinter)
    pp.add_printer("Null", "^nebula::NullType$", NullPrinter)
    pp.add_printer("Date", "^nebula::Date$", DatePrinter)
    pp.add_printer("Time", "^nebula::Time$", TimePrinter)
    pp.add_printer("DateTime", "^nebula::DateTime$", DateTimePrinter)
    #pp.add_printer("Edge", "^nebula::Edge$", EdgePrinter)
    #pp.add_printer("Vertex", "^nebula::Vertex$", VertexPrinter)
    return pp

gdb.printing.register_pretty_printer(gdb.current_progspace(), build_nebula_printers())

end
