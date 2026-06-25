# nebula-gears: update version, build, and install

3 parts
0. update the GCC version or LLVM version
1. use `nebula-gears` to build `nebula-gears-installer.sh`
2. use the installation script to prepare `GCC 11.2.0`, then continue building `GCC 13.4.0`

## 0 update the Gcc version 
when gcc update to new version ,example  13.4.0
like  `/share/nebula-gears/gcc-tarball-info-13.4.0`

## 1.Create a new tag  and Clone nebula-gears 

```bash
git clone https://github.com/vesoft-inc/nebula-gears.git
cd /root/nebula-gears
git fetch --tags
git describe --tags --abbr=0
```

Notes:

- `git fetch --tags` syncs the repository tags.
- `git describe --tags --abbr=0` checks the latest available tagged version.

## 2. Build the nebula-gears installer package

```bash
cmake -S . -B build -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/usr/local
cmake --build build --target package
```

The key artifact produced is:

```bash
build/nebula-gears-installer.sh
```

You can run two checks first:

```bash
bash build/nebula-gears-installer.sh --version
ls -l build/nebula-gears-installer.sh
```

## 3. Install the base GCC toolchain

The goal here is to first use the installation capability provided by `nebula-gears` to install a usable `GCC 11.2.0`, and then use it to build `GCC 13.4.0`.

If you are still in the `nebula-gears` repository directory, run:

```bash
bash install
```

Prepare the build directory for GCC 13:

```bash
mkdir -p /root/nebula-gcc13
```

Install `GCC 11.2.0`:

```bash
sudo /usr/local/bin/install-gcc --version=11.2.0
```

Enable and verify `GCC 11.2.0`:

```bash
source /opt/vesoft/toolset/gcc/11.2.0/enable
gcc --version
g++ --version
```

## 4. Build GCC 13.4.0

Enter the build directory:

```bash
cd /root/nebula-gcc13
```

Use `GCC 11.2.0` as the compiler to build `GCC 13.4.0`:

```bash
CC=/opt/vesoft/toolset/gcc/11.2.0/bin/gcc \
CXX=/opt/vesoft/toolset/gcc/11.2.0/bin/g++ \
/usr/local/bin/build-gcc --version=13.4.0
```

## 5. Use GCC 13.4.0

After the build completes, enable the new toolchain:

```bash
source /opt/vesoft/toolset/gcc/13.4.0/enable
export LD_LIBRARY_PATH=/opt/vesoft/toolset/gcc/13.4.0/lib64:$LD_LIBRARY_PATH
```

Verification is recommended:

```bash
gcc --version
g++ --version
```