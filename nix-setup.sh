#!/bin/bash
set -eo pipefail

NIX_VERSION=2.23.1
NIX_HASH=c7cf1492f642fdfdc3f1ca8ebaad03274282720565b55f5144aba4850a44a3da
NIX_SOURCE=https://github.com/NixOS/nix/archive/${NIX_VERSION}/nix-${NIX_VERSION}.tar.gz

echo "Downloading nix version ${NIX_VERSION}..."
wget -q -O nix.tar.gz ${NIX_SOURCE}
DL_SUM=$(sha256sum nix.tar.gz | cut -d" " -f1)
if [ $DL_SUM != $NIX_HASH ]; then
    echo "Downloaded file hash mismatch!"
    echo "URL: $NIX_SOURCE"
    echo "Got: $DL_SUM"
    echo "Expected: $NIX_HASH"
    exit 1
fi

mkdir -p nix
tar --strip-components=1 -C nix -xf ./nix.tar.gz
rm nix.tar.gz
cd nix
autoreconf -vfi
bash ./configure --prefix=/usr/local --disable-doc-gen --disable-unit-tests CFLAGS="-fPIC"
make -j$(nproc)
sudo make install
sudo nix-store --realise
cd ../
rm -rf ./nix

