#!/bin/bash
set -eo pipefail

LOWDOWN_VERSION=1200b9f4ceceb5795ccc0a02a2105310f0819222
LOWDOWN_SOURCE=https://github.com/kristapsdz/lowdown/archive/${LOWDOWN_VERSION}.tar.gz

# wget -q -O- https://github.com/kristapsdz/lowdown/archive/${LOWDOWN_VERSION}.tar.gz | \
#     tee >(sha256sum | cut -d' ' -f1 | \
#     xargs -I {} sed -i 's/LOWDOWN_HASH=.*/LOWDOWN_HASH={}/' lowdown-setup.sh) >/dev/null
LOWDOWN_HASH=ace39b836bff0acedae9f0acdcbe33f18322145b2faa22b4d4a74b75b8e69637

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
tar -C lowdown -xf ./lowdown.tar.gz --strip-components=1
rm lowdown.tar.gz
cd lowdown
CFLAGS="-fPIC" ./configure PREFIX=/usr/local
make -j$(nproc)
sudo make install
cd ../
rm -rf lowdown
