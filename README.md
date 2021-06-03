# nebula-gears
Gears for Nebula Graph

# Install Prebuilt Package

Before starting, serveral dependencies need to installed:
 * `lsb_release` from package lsb-core(Debian derivatives) or redhat-lsb-core(RedHat derivatives).
 * wget
 * curl

The default installation prefix is `/usr/local`, which requires root privilege to write.

```shell
$ URL=https://raw.githubusercontent.com/vesoft-inc/nebula-gears/master/install

# Install with sudo:
$ sudo bash -s < <(curl -Ls $URL)

# Install with customized prefix:
$ bash <(curl -Ls $URL) --prefix=...
```

# Tools

## `install-gcc`
```shell
$ install-gcc
Please specify the version you want to install with --version=x.y.z
Optional versions are: 7.1.0 7.3.0 7.5.0 8.3.0 9.1.0 9.2.0 10.1.0

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
Optional versions are: 9.0.0

$ install-llvm --version=9.0.0
...

$ install-llvm --version=all
...
```


## `install-cmake`
```shell
$ install-cmake
CMake-3.15.7 has been installed to /opt/vesoft/toolset/cmake
Please run 'source /opt/vesoft/toolset/cmake/enable' to start using.
Please run 'source /opt/vesoft/toolset/cmake/disable' to stop using.
```

# Build GCC and LLVM
This requires you have appropriate OSS configurations at `$HOME/.ossutilconfig`.

```shell
$ git clone https://github.com/vesoft-inc/nebula-gears.git
$ cd nebula-gears/docker/build

# Print all supported platforms
$ make print
centos-7 debian-9

# Build GCC and LLVM for all provided platforms
$ make

# Only build GCC
$ make gcc-centos-7

# Build GCC 9.1.0 and 8.3.0, LLVM 9.0.0
$ make BUILD_GCC_VERSIONS=8.3.0,9.1.0 BUILD_LLVM_VERSIONS=9.0.0 debian-9
```

Note that you could perform the same steps to build for x86_64 and aarch64


# Build Toolset Docker Images
This requires you have logged in on the DockerHub.
```shell
$ git clone https://github.com/vesoft-inc/nebula-gears.git
$ cd nebula-gears/docker/images

$ make print
centos-7 debian-9
$ make centos-7
$ make debian-9
```

Note that you could perform the same steps to build for x86_64 and aarch64


# Maintain
```shell
# To make a release on GitHub
$ git tag vx.y.z
$ git push origin vx.y.z

# To update to the lastest version
$ sudo nebula-gears-update

# To uninstall
$ sudo nebula-gears-uninstall

# To show all installed files
$ sudo nebula-gears-show-files
```
