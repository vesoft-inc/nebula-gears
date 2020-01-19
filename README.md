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
