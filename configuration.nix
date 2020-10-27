{ config, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/docker-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  security.audit.enable = false;
  networking.firewall.enable = false;
  networking.networkmanager.enable = false;
  networking.wireless.enable = false;
  documentation.doc.enable = false;

  # this section may be unnecessary
  boot.isContainer = true;
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };

  nixpkgs.config = {
    allowUnfree = true; # Allow "unfree" packages.

    # firefox.enableAdobeFlash = true;
    # chromium.enablePepperFlash = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bashInteractive
    cacert
    nix
    tree
    wget
    git
    gnupg
    curl
    tmux
    gnumake
    unzip
  ];           

  environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };
}