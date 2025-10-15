#!/bin/bash
set -eo pipefail

BLAKE3_VERSION=1.8.2
BLAKE3_HASH=6b51aefe515969785da02e87befafc7fdc7a065cd3458cf1141f29267749e81f
BLAKE3_SOURCE=https://github.com/BLAKE3-team/BLAKE3/archive/refs/tags/${BLAKE3_VERSION}.tar.gz

echo "Downloading BLAKE3 version ${BLAKE3_VERSION}..."
wget -q -O blake3.tar.gz ${BLAKE3_SOURCE}
DL_SUM=$(sha256sum blake3.tar.gz | cut -d" " -f1)
if [ $DL_SUM != $BLAKE3_HASH ]; then
    echo "Downloaded file hash mismatch!"
    echo "URL: $BLAKE3_SOURCE"
    echo "Got: $DL_SUM"
    echo "Expected: $BLAKE3_HASH"
    exit 1
fi

mkdir -p blake3
tar -C blake3 -xf ./blake3.tar.gz --strip-components=1
rm blake3.tar.gz
cd blake3/c
mkdir -p build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local ..
make -j$(nproc)
sudo make install
cd ../../../
rm -rf blake3
