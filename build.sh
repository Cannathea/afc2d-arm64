#/bin/sh

make clean
make package

export -n PREFIX
make clean
make package THEOS_PACKAGE_SCHEME=rootless
