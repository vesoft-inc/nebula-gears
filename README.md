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


## `install-gdb`
Installation of GDB is not relocatable, and will be installed at `/opt/vesoft/toolset/gdb/x.y.z`.
```shell
$ install-gdb --version=8.3
GDB-8.3 has been installed to /opt/vesoft/toolset/gdb/8.3
Please run 'source /opt/vesoft/toolset/gdb/8.3/enable' to start using.
Please run 'source /opt/vesoft/toolset/gdb/8.3/disable' to stop using.
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
$ elf-isa `which gcc`
BASE
      jp, jb, jae, jns, jmp, jne, hlt, ret, call, jl, jg, jbe, jge, je, js
      ja, jle
BMI
      tzcnt
CMOV
      cmovg, cmovl, cmove, cmovns, cmovle, cmova, cmovb, cmovbe, cmovge
      cmovae, cmovne, cmovs
MODE64
      leave, ret, lea, push, jmp, pop, call, movsxd
SSE1
      movups, movaps
SSE2
      subsd, pmovmskb, divsd, movdqu, pxor, movq, movsd, por, mulsd, pcmpeqb
      addsd, movapd, movdqa, ucomisd
SSE42
      pcmpestri

126139 instructions disassembled

$ elf-isa `which elf-isa`
BASE
      bnd ret, jp, syscall, jb, jae, jrcxz, jmp, bnd call, bnd jmp, jne, hlt
      jns, ret, js, je, call, jl, jge, jbe, jg, jle, bnd jns, ja
AVX
      vpcmpeqq, vpcmpistri, vpsrldq, vpxor, vpor, vpshufb, vpminub, vpslldq
      vpmovmskb, vmovntdq, vmovdqa, vmovdqu, vpcmpgtb, vzeroupper, vpsubb, vmovq
      vpand, vmovd, vptest, vpcmpeqb, vpandn
AVX2
      vpcmpeqd, vpbroadcastd, vpand, vpor, vpminud, vpxor, vpminub, vpcmpeqb
      vpmovmskb, vpbroadcastb
AVX512
      vmovdqa64, vmovups, vbroadcastss, vmovntdq, vmovdqu64, vmovaps
BMI
      tzcnt
CMOV
      cmove, cmova, cmovle, cmovns, cmovbe, cmovb, cmovne, cmovae, cmovs
      cmovge, cmovg, cmovl
MODE64
      bnd ret, bnd call, bnd jmp, leave, ret, lea, push, jmp, pop, call
      movsxd
SSE1
      movss, divss, stmxcsr, movmskps, prefetchnta, prefetcht1, movaps
      movups, prefetcht0, sfence
SSE2
      pcmpeqd, pcmpgtb, lfence, punpcklwd, pmaxub, pshufd, punpcklbw, movd
      ucomisd, movq, psubb, subsd, pcmpeqb, cvttsd2si, andnpd, movdqu, pminub
      pxor, movapd, addsd, movsd, orpd, movmskpd, movntdq, movlpd, andpd, movhpd
      comisd, psrldq, cmpnlesd, pmovmskb, pand, pslldq, movdqa, por
SSE3
      lddqu
SSE41
      pminud, ptest
SSE42
      pcmpistri
SSSE3
      pshufb
NOT64BITMODE
      xchg
NOVLX
      vpcmpeqq, vpand, vpor, vpminub, vpxor, vpminud, vpcmpeqb, vpandn
      vpsubb, vmovntdq, vpcmpgtb, vpcmpeqd
FPU
      wait, fxam, fabs, fucomi, fdiv, fucompi, fld, fstp, fild, fxch, fnstenv
      fcomi, fldz, fldenv, fmul, fadd, fmulp, fldcw

180460 instructions disassembled
```


# Build Toolset
Currently, _Nebula_ toolset build consists of GCC and LLVM on various Linux platforms:
  * CentOS 6/7 for GCC, and CentOS 6/7/8 for LLVM
  * Debian 7/8 for GCC, and Debian 8/9/10 for LLVM

```shell
$ git clone https://github.com/dutor/nebula-gears.git
$ cd nebula-gears/docker/toolset/build

# Build GCC and LLVM for all provided platforms
$ make

# Build GCC and LLVM for specific platform
$ make centos-7

# Only build GCC
$ make gcc-centos-7

# Build GCC 9.1.0 and 8.3.0, LLVM 9.0.0
$ make BUILD_GCC_VERSIONS=8.3.0,9.1.0 BUILD_LLVM_VERSIONS=9.0.0 centos-6
```

After the build succeeds, all resulting packages will be located in the `$PWD/toolset-packages` subdirectory. If you want the packages uploaded to the OSS repository for public access, the `$HOME/.ossutilconfig` file must exists, which holds the necessary access tokens.

# Build Nebula Third Party

Currently, _Nebula_ third party build supports various Linux platforms:
  * Centos 6/7
  * Ubuntu 1604/1804

```shell
$ git clone https://github.com/dutor/nebula-gears.git
$ cd nebula-gears/docker/third-party/build

# Build for all provided platforms
$ make

# Build for specific platform
$ make ubuntu-1604

# Build with GCC 7.5.0 and 9.2.0
$ make USE_GCC_VERSIONS=7.5.0,9.2.0 ubuntu-1804
```

After the build succeeds, all resulting packages will be located in the `$PWD/third-party-packages` subdirectory. If you want the packages uploaded to the OSS repository for public access, the `$HOME/.ossutilconfig` file must exists, which holds the necessary access tokens.
