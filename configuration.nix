{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <nixpkgs/nixos/modules/virtualisation/docker-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  documentation.doc.enable = false;
  security.audit.enable = false;
  networking.firewall.enable = false;
  networking.networkmanager.enable = false;
  networking.wireless.enable = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

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
    vim
  ];           

  environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };
}