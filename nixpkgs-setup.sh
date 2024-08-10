#!/bin/bash
set -eo pipefail

# previous working version:
# NIXPKGS_VERSION=v208
# NIXPKGS_HASH=b49b7aa90e89fe1016036d2f770975f3322b8724401b534b4a356046cba424ee

NIXPKGS_VERSION=24.05
NIXPKGS_HASH=911314b81780f26fdaf87e17174210bdbd40c86bac1795212f257cdc236a1e78

NIXPKGS_SOURCE=https://github.com/NixOS/nixpkgs/archive/${NIXPKGS_VERSION}/nixos-${NIXPKGS_VERSION}.tar.gz

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
