#!/bin/bash
set -eo pipefail

EDITLINE_VERSION=1.17.1
EDITLINE_HASH=df223b3333a545fddbc67b49ded3d242c66fadf7a04beb3ada20957fcd1ffc0e
# EDITLINE_SOURCE=https://github.com/troglobit/editline/archive/${EDITLINE_VERSION}/editline-${EDITLINE_VERSION}.tar.gz
EDITLINE_SOURCE=http://gentoo.osuosl.org/distfiles/88/editline-${EDITLINE_VERSION}.tar.xz

echo "Downloading editline version ${EDITLINE_VERSION}..."
wget -O editline.tar.xz ${EDITLINE_SOURCE}
DL_SUM=$(sha256sum editline.tar.xz | cut -d" " -f1)
if [ $DL_SUM != $EDITLINE_HASH ]; then
    echo "Downloaded file hash mismatch!"
    echo "URL: $EDITLINE_SOURCE"
    echo "Got: $DL_SUM"
    echo "Expected: $EDITLINE_HASH"
    exit 1
fi

mkdir -p editline
tar --strip-components=1 -C editline -xf ./editline.tar.xz
rm editline.tar.xz
cd editline
# ./autogen.sh
./configure --prefix=/usr/local --disable-seccomp-sandboxing --disable-manual
make -j4
sudo make install
cd ..
rm -rf editline
