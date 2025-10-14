#!/bin/bash
set -eo pipefail

NIXPKGS_VERSION=25.05
NIXPKGS_HASH=130b4257b3d53bfbfea6d61fb76d4751a3989a4a09a28615ff77516a82b3924d
NIXPKGS_SOURCE=https://github.com/NixOS/nixpkgs/archive/${NIXPKGS_VERSION}.tar.gz

echo "Downloading nixpkgs version ${NIXPKGS_VERSION}..."
cd ~
wget -q -O nixpkgs.tar.gz ${NIXPKGS_SOURCE}
DL_SUM=$(sha256sum nixpkgs.tar.gz | cut -d" " -f1)
if [ $DL_SUM != $NIXPKGS_HASH ]; then
    echo "Downloaded file hash mismatch!"
    echo "URL: $NIXPKGS_SOURCE"
    echo "Got: $DL_SUM"
    echo "Expected: $NIXPKGS_HASH"
    exit 1
fi

mkdir -p nix-path/nixpkgs
tar --strip-components=1 -C nix-path/nixpkgs -xf ./nixpkgs.tar.gz
rm nixpkgs.tar.gz
#cd nix-path/nixpkgs
#cd ../../
