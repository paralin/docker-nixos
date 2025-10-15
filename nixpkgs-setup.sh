#!/bin/bash
set -eo pipefail

NIXPKGS_VERSION=25.05-20251014
NIXPKGS_COMMIT=a493e93b4a259cd9fea8073f89a7ed9b1c5a1da2
NIXPKGS_HASH=2766f53095c62b417dc283fb9f8a0c3447ad3e138f4686426c5fdd0b7e595a0b
NIXPKGS_SOURCE=https://github.com/NixOS/nixpkgs/archive/${NIXPKGS_COMMIT}/nixpkgs-${NIXPKGS_VERSION}.tar.gz

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

