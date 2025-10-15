#!/bin/bash
set -eo pipefail

NIX_VERSION=2.32.1
NIX_HASH=879e05682a35aefe7fc8c570475ce8deb93e0324ac3d6cccadd060de2b481947
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
meson setup build --prefix=/usr/local -Dunit-tests=false -Ddoc-gen=false
meson compile -C build -j$(nproc)
sudo meson install -C build
sudo ldconfig
sudo nix-store --realise
cd ../
rm -rf ./nix

