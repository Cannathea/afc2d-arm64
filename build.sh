#/bin/sh

export PREFIX=$THEOS/toolchain/Xcode11.xctoolchain/usr/bin/
make clean
make package install

export -n PREFIX
make clean
make package THEOS_PACKAGE_SCHEME=rootless
