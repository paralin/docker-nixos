#!/bin/bash
set -eo pipefail

sudo chown -R $(whoami) /nix
source /usr/local/etc/profile.d/nix.sh
nix-env -i

# source $HOME/.nix-profile/etc/profile.d/nix.sh
# nix-env --upgrade

# install nixos
cd $HOME/sys-config
nix-build -I nixpkgs=$HOME/nix-path/nixpkgs --option sandbox false default.nix
# move tarball out
sudo mv ./result/tarball/nixos-system-*-linux.tar.xz ./result.tar.xz
sudo chown $(whoami) ./result.tar.xz
rm result
# clear old envs + GC
rm /nix/var/nix/gcroots/auto/* || true
# garbage collect the store
nix-store --gc
nix-collect-garbage -d
