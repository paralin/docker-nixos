#!/bin/bash
set -eo pipefail

# NIX_VERSION=2.3.10
# NIX_HASH=04e1c7c625b753df35bf0e0a952d1a886fd6c6b582190832d57a7269241b4b50

NIX_VERSION=2.3.15
NIX_HASH=87f72f8bb2b980c3903ee63112ab15033ea98da0afef99bff678154511c24bb7

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
./bootstrap.sh
bash ./configure --prefix=/usr/local --disable-doc-gen
make -j4
sudo make install
sudo nix-store --realise
cd ../
rm -rf ./nix

