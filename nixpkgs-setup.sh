#!/bin/bash
set -eo pipefail

# NIXOS_VERSION=20.09
# NIXOS_HASH=83767a5196b3899ae4a2be30feceadf6d8839d2684807f63455d02450f32f4c9

NIXOS_VERSION=85abeab48b5feda4b163e5bb32f50aad1164e415
NIXOS_HASH=91646be57a901f50a53411a075946701c9aeb6d515c2e8df3c42b1339f0ee0a7

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
