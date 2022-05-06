#!/bin/bash
set -eo pipefail

# previous working version:
# NIXOS_VERSION=21.05
# NIXOS_HASH=16b86dd4c19ffbd93f1d225df1b0f179bf0e418fd9ce9337ff491762a65658e7

NIXOS_VERSION=21.11
NIXOS_HASH=c77bb41cf5dd82f4718fa789d49363f512bb6fa6bc25f8d60902fe2d698ed7cc

NIXOS_SOURCE=https://github.com/NixOS/nixpkgs/archive/${NIXOS_VERSION}/nixos-${NIXOS_VERSION}.tar.gz

echo "Downloading nixpkgs version ${NIXOS_VERSION}..."
cd ~
wget -q -O nixpkgs.tar.gz ${NIXOS_SOURCE}
DL_SUM=$(sha256sum nixpkgs.tar.gz | cut -d" " -f1)
if [ $DL_SUM != $NIXOS_HASH ]; then
    echo "Downloaded file hash mismatch!"
    echo "URL: $NIXOS_SOURCE"
    echo "Got: $DL_SUM"
    echo "Expected: $NIXOS_HASH"
    exit 1
fi

mkdir -p nix-path/nixpkgs
tar --strip-components=1 -C nix-path/nixpkgs -xf ./nixpkgs.tar.gz
rm nixpkgs.tar.gz
#cd nix-path/nixpkgs
#cd ../../
