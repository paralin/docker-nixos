# system = "x86_64-linux";
let
  nixos = import <nixpkgs/nixos> {
    configuration = ./configuration.nix;
  };
in
nixos.config.system.build.tarball