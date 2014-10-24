#!/bin/bash
set -e
ver=$(git describe --tags --dirty="+" --match="v*" "${flags[@]}" | sed -e 's@-\([^-]*\)-\([^-]*\)$@+\1.\2@;s@^v@@;s@%@~@g')
sudo rm -rf _
mkdir -p _/DEBIAN
cycc -i2.0 -o_/DEBIAN/extrainst_ -- extrainst.mm -lz -framework Foundation
cycc -i2.0 -o_/DEBIAN/postrm -- postrm.mm -lz -framework Foundation
sed -e 's/\${ver}/'"${ver}"'/' control.in >_/DEBIAN/control
mkdir -p _/usr/libexec
cp -a afc2d _/usr/libexec
deb=com.saurik.afc2d_${ver}_iphoneos-arm.deb
sudo chown -R root:wheel _
sudo dpkg-deb -b _ "${deb}"
#sudo rm -rf _
ln -sf com.saurik.afc2d.deb "${deb}"
