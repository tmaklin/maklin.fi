---
author: "Tommi M&auml;klin"
title: "Cross-compiling C++ binaries for macOS arm64 and x86_64"
date: "2023-12-12"
draft: false
description: "Precompiled binaries are the easiest way to install C++ software but they can be a pain to create."
category: "software-development"
tags: [
	"cross-compiling",
	"cpp-development",
	"macos"
]
---

_there's an example script for cross-compiling at the end_

Installing software made by other people is one of the several annoying and time-consuming tasks I have to deal with as a bioinformatician. Luckily tools like conda have become much more widespread than they were when I started my career in 2016 but the prebuilt binary remains my go-to choice due to it's simplicity - provided that one is made available by the maintainers.

Personally I try to provide binaries for my own tools, but cross-compiling for macOS has become a major annoyance after my first (and last if I have a say in the matter) macOS laptop died a while ago. Apple's transition to the arm64 architecture made the situation worse since maintaining macOS binaries would now require two laptops.

## Prebuilding binaries for other Linux distros is easy in a Docker container
For my prebuilt Linux x86\_64 C++ binaries, I have been using the [Holy Build Box](https://phusion.github.io/holy-build-box/) for a few years to create executables that run on different distros without problems. Holy Build Box accomplishes this by compiling the binaries in a Docker container that contains a minimal and the oldest possible Linux install that supports whatever C++ standard you happen to be interested in using. I originally came across this approach in a [blog post by P&aacute;ll Melsted](https://pmelsted.wordpress.com/2015/10/14/building-binaries-for-bioinformatics/). You can find an example of the wrapper scripts I use on [GitHub](https://github.com/tmaklin/biobins/tree/master/linux/mSWEEP).

Unfortunately a Holy Build Box style container for macOS builds did not really at the time I created by build scripts, so I was relegated to compiling the binaries on the hardware I had at the time and hoping that they run on other people's macs. This obviously didn't work anymore with the arm64 and x86\_64 architecture mismatch and although cross-compiling from x86\_64 macs to arm64 ones might be possible I just decided to drop support altogether and instruct people to install my tools for mac from bioconda.

## Cross-compiling for macOS from a Linux environment
Recently, I discovered the [macOS Cross Compiler](https://github.com/shepherdjerred/macos-cross-compiler) project by [Jerred Shepherd](https://sjer.red/) which provides exactly what Holy Build Box project does - a Docker container that sets up an environment where building results in binaries that run on mac under the target architecture. This is great.

Setting up the macOS cross compiler is a bit of work but the result seems to do exactly what I want and calling it is very similar to how I had set up the Linux binaries. I currently use the macOS Cross Compiler to build binaries for [mSWEEP](https://github.com/probic/msweep), which are detailed below.

### Example: compiling mSWEEP for macOS arm64 and x86_64
[My workflow](https://github.com/tmaklin/biobins/tree/master/macOS/mSWEEP) consists of two scripts:

`compile_in_docker.sh` sets up the compiler toolchain for the target architecture and calls the `build.sh` script inside a Docker container:
```
#!/bin/sh
## Wrapper for calling the build script `build.sh` inside the
## macoss-cross-compiler docker container. 
#
# Arguments
## 1: version number to build (checked out from the git source tree)
## 2: architecture (one of x86-64,arm64)

set -eo pipefail

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version as argument 1"
  exit;
fi

ARCH=$2
if [[ -z $ARCH ]]; then
  echo "Error: specify architecture (one of x86-64,arm64) as argument 2"
  exit;
fi

set -ux

cp ../$2-toolchain.cmake ./

docker run \
  -v `pwd`:/io \
  --rm \
  -it \
  ghcr.io/shepherdjerred/macos-cross-compiler:latest \
  /bin/bash /io/build.sh $1 $2

rm $2-toolchain.cmake
```
In the script above the `$ARCH-toolchain.cmake` file defines cmake environment variables that point to the compiler toolchain that's needed. Have a look at the .cmake files in [tmaklin/biobins](https://github.com/tmaklin/biobins/blob/master/macOS) for an example.

The second script, `build.sh`, is specific to the project I'm building and defines how the source should be compiled and which files are included in the release tarball. For mSWEEP, this consists of
```
#!/bin/bash
## Build script for cross-compiling mSWEEP for macOS x86-64 or arm64.
## Call this from `compile_in_docker.sh` unless you know what you're doing.

set -exo pipefail

VER=$1
if [[ -z $VER ]]; then
  echo "Error: specify version"
  exit;
fi

ARCH=$2
if [[ -z $ARCH ]]; then
  echo "Error: specify architecture (one of x86-64,arm64)"
  exit;
fi

apt update
apt install -y cmake git libomp5 libomp-dev

# Extract and enter source
mkdir /io/tmp && cd /io/tmp
git clone https://github.com/PROBIC/mSWEEP.git
cd mSWEEP
## git checkout v${VER}
git checkout cross-compilation-compatibility

# compile x86_64
mkdir build
cd build
if [ "$ARCH" = "x86-64" ]; then
    cmake -DCMAKE_TOOLCHAIN_FILE="/io/$ARCH-toolchain.cmake" \
          -DCMAKE_C_FLAGS="-march=$ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DCMAKE_CXX_FLAGS="-march=$ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DBZIP2_LIBRARIES="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libbz2.tbd" -DBZIP2_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DZLIB_LIBRARY="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libz.tbd" -DZLIB_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DCMAKE_BUILD_WITH_FLTO=0  ..
elif [ "$ARCH" = "arm64" ]; then
    cmake -DCMAKE_TOOLCHAIN_FILE="/io/$ARCH-toolchain.cmake" \
          -DCMAKE_C_FLAGS="-arch $ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DCMAKE_CXX_FLAGS="-arch $ARCH -mtune=generic -m64 -fPIC -fPIE" \
          -DBZIP2_LIBRARIES="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libbz2.tbd" -DBZIP2_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DZLIB_LIBRARY="/osxcross/SDK/MacOSX13.0.sdk/usr/lib/libz.tbd" -DZLIB_INCLUDE_DIR="/osxcross/SDK/MacOSX13.0.sdk/usr/include" \
          -DCMAKE_BUILD_WITH_FLTO=0  ..
fi
make VERBOSE=1 -j

## gather the stuff to distribute
target=mSWEEP_macos-$ARCH-v${VER}
target=$(echo $target | sed 's/x86-64/x86_64/g')
path=/io/tmp/$target
mkdir $path
cp ../build/bin/mSWEEP $path/
cp ../CHANGELOG.md $path/
cp ../README.md $path/
cp ../LICENSE $path/
cd /io/tmp
tar -zcvf $target.tar.gz $target
mv $target.tar.gz /io/
cd /io/
rm -rf tmp cache
```

In the end we have the `mSWEEP_macos-$ARCH-v${VER}` tarball containing the prebuilt binary. Neat!
