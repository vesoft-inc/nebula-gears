# nebula-gears
Gears for Nebula Graph

# Install Prebuilt Package

Before starting, serveral dependencies need to installed:
 * `lsb_release` from package lsb-core(Debian derivatives) or redhat-lsb-core(RedHat derivatives).
 * wget
 * curl

The default installation prefix is `/usr/local`, which requires root privilege to write.

```shell
$ URL=https://raw.githubusercontent.com/dutor/nebula-gears/master/install

# Install with sudo:
$ sudo bash -s < <(curl -s $URL)

# Install with customized prefix:
$ bash <(curl -s $URL) --prefix=...
```

# Tools

## `install-gcc`
```shell
$ install-gcc
Please specify the version you want to install with --version=x.y.z
Optional versions are: 5.1.0 5.3.0 5.5.0 6.1.0 6.3.0 6.5.0 7.1.0 7.3.0 7.5.0 8.3.0 9.1.0 9.2.0

# By default GCC will be installed at /opt/vesoft/toolset/gcc/x.y.z
$ install-gcc --version=9.2.0
...

# Changed prefix
$ install-gcc --version=9.2.0 --prefix=/usr/local

# Install all available versions
$ install-gcc --version=all
...
```

## `install-llvm`
Installation of LLVM is not relocatable, and will be installed at `/opt/vesoft/toolset/clang/x.y.z`.
```shell
$ install-llvm
Please specify the version you want to install with --version=x.y.z
Optional versions are: 8.0.0 9.0.0

$ install-llvm --version=9.0.0
...

$ install-llvm --version=all
...
```

## `elf-size`
```shell
$ elf-size bin/nebula-graphd
.debug_info                46.4MB  35.8%
.strtab                    32.7MB  25.2%
.text                      20.5MB  15.8%
.debug_str                 8.50MB   6.6%
.eh_frame                  5.57MB   4.3%
.symtab                    5.40MB   4.2%
.rodata                    3.54MB   2.7%
.debug_line                2.42MB   1.9%
.eh_frame_hdr              1.25MB   1.0%
.debug_ranges               846KB   0.6%
.debug_aranges              842KB   0.6%
.gcc_except_table           743KB   0.6%
.debug_abbrev               432KB   0.3%
.data.rel.ro.local          212KB   0.2%
.data.rel.ro                192KB   0.1%
TOTAL                       130MB 100.0%

$ elf-size /opt/vesoft/third-party/lib/liba*.a
----------------------------------------
/opt/vesoft/third-party/lib/libaio.a
----------------------------------------
.symtab                    2.23KB  31.7%
.shstrtab                    923B  12.8%
.text                        862B  12.0%
[ELF Headers]                704B   9.8%
.eh_frame                    656B   9.1%
[AR Symbol Table]            490B   6.8%
.strtab                      391B   5.4%
.comment                     363B   5.0%
.rela.eh_frame               312B   4.3%
.rela.text                   216B   3.0%
TOTAL                      7.03KB 100.0%
----------------------------------------
/opt/vesoft/third-party/lib/libasync.a
----------------------------------------
.strtab                     687KB  22.2%
[AR Symbol Table]           578KB  18.6%
.shstrtab                   507KB  16.4%
.symtab                     379KB  12.2%
.eh_frame                   128KB   4.1%
.rela.eh_frame              104KB   3.3%
.group                     46.3KB   1.5%
.rodata                    31.8KB   1.0%
.rela.text                 16.3KB   0.5%
.text                      15.1KB   0.5%
.rela.text._ZN6apach...    4.92KB   0.2%
.rela.text._ZNSt6vec...    4.50KB   0.1%
.text._ZN6apache6thr...    4.17KB   0.1%
.text._ZNSt6vectorIP...    4.14KB   0.1%
.rela.data.rel.ro._Z...    3.68KB   0.1%
.rela.data.rel.ro._Z...    3.38KB   0.1%
.gcc_except_table          3.22KB   0.1%
TOTAL                      3.03MB 100.0%
```

## `elf-isa`
```shell
```
