#!/bin/bash
set -eo pipefail

source /usr/local/etc/profile.d/nix.sh

# install nixos
export NIX_PATH=/home/builder/nix-path
cd /home/builder/sys-config
nix-build \
    --option sandbox false \
    -I nixos-config=$(pwd)/configuration.nix \
    -A system \
    '<nixpkgs/nixos>'
# target_system=$(readlink -f ./result)
# nix-env -p /nix/var/nix/profiles/system --set $target_system

touch ./result/etc/NIXOS
mkdir -p ./result/etc/nixos/
cp configuration.nix ./result/etc/nixos/

cp -r $(pwd)/result/* /sys-root/
mkdir -p /sys-root/run/systemd/
mkdir -p /sys-root/root
rm result
