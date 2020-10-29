#!/bin/bash
set -eo pipefail

# NIX_VERSION=a5019f0508be961bf0230d2a528d30d3ded4b12a
# NIX_HASH=d760e6f3af1f645384761703097b47e988e8d89829183a5690448dcfd4f329fe
NIX_VERSION=2.3.8
NIX_HASH=a9a0474753abfb61c7de97d4323684465e24be67ce3357252ccd45441ab8d267
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

