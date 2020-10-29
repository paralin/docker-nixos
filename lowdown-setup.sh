#!/bin/bash
set -eo pipefail

LOWDOWN_VERSION=0.7.4
LOWDOWN_HASH=21bb1cad16a71a3b218965ea7109592ef7f22853eb46f0448af99741bf26c052
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
tar --strip-components=2 -C lowdown -xf ./lowdown.tar.gz
rm lowdown.tar.gz
cd lowdown
# ./autogen.sh
./configure PREFIX=/usr/local
make -j4
sudo make install
cd ../
rm -rf lowdown
