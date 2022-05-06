#!/bin/bash
set -eo pipefail

LOWDOWN_VERSION=0.9.2
LOWDOWN_HASH=5c355d1db2071916b1ad6e789208de664be3781bd17dd8b6b09b1707a283a988

LOWDOWN_SOURCE=https://kristaps.bsd.lv/lowdown/snapshots/lowdown-${LOWDOWN_VERSION}.tar.gz

echo "Downloading lowdown version ${LOWDOWN_VERSION}..."
wget -q -O lowdown.tar.gz ${LOWDOWN_SOURCE}
DL_SUM=$(sha256sum lowdown.tar.gz | cut -d" " -f1)
if [ $DL_SUM != $LOWDOWN_HASH ]; then
    echo "Downloaded file hash mismatch!"
    echo "URL: $LOWDOWN_SOURCE"
    echo "Got: $DL_SUM"
    echo "Expected: $LOWDOWN_HASH"
    exit 1
fi

mkdir -p lowdown
tar --strip-components=1 -C lowdown -xf ./lowdown.tar.gz
rm lowdown.tar.gz
cd lowdown
# ./autogen.sh
CFLAGS="-fPIC" ./configure PREFIX=/usr/local
make -j4
sudo make install
cd ../
rm -rf lowdown
