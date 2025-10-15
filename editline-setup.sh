#!/bin/bash
set -eo pipefail

EDITLINE_VERSION=1.17.2-pre-r1
EDITLINE_COMMIT=f735e4d1d566cac3caa4a5e248179d07f0babefd
EDITLINE_HASH=e4f6614d132f9a52f862dc5e4b5df0b0ac1d523eb60d21764ed4c295b580ffc7
EDITLINE_SOURCE=https://github.com/troglobit/editline/archive/${EDITLINE_COMMIT}/editline-${EDITLINE_VERSION}.tar.gz

echo "Downloading editline version ${EDITLINE_VERSION}..."
wget -O editline.tar.gz ${EDITLINE_SOURCE}
DL_SUM=$(sha256sum editline.tar.gz | cut -d" " -f1)
if [ $DL_SUM != $EDITLINE_HASH ]; then
    echo "Downloaded file hash mismatch!"
    echo "URL: $EDITLINE_SOURCE"
    echo "Got: $DL_SUM"
    echo "Expected: $EDITLINE_HASH"
    exit 1
fi

mkdir -p editline
tar --strip-components=1 -C editline -xf ./editline.tar.gz
rm editline.tar.gz
cd editline
./autogen.sh
./configure --prefix=/usr/local --disable-seccomp-sandboxing --disable-manual
# Disable building examples to avoid compilation errors
sed -i 's/SUBDIRS = src include man examples/SUBDIRS = src include man/' Makefile
make -j$(nproc)
sudo make install
cd ..
rm -rf editline
