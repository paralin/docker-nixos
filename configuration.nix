{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <nixpkgs/nixos/modules/virtualisation/docker-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  documentation.doc.enable = false;
  networking.firewall.enable = false;
  networking.interfaces.eth0.useDHCP = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.networkmanager.enable = false;
  networking.resolvconf.dnsExtensionMechanism = false;
  networking.useDHCP = false;
  networking.wireless.enable = false;
  security.audit.enable = false;
  systemd.enableEmergencyMode = false;
  systemd.services.rescue.enable = false;

  boot.isContainer = true;
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = false;
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

  nixpkgs.config = {
    allowUnfree = true; # Allow "unfree" packages.

    # firefox.enableAdobeFlash = true;
    # chromium.enablePepperFlash = true;
  };

  environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };

  # don't set sycstl values in a container
  systemd.services.systemd-sysctl.restartTriggers = lib.mkForce [ ];
  environment.etc."sysctl.d/60-nixos.conf" = lib.mkForce { text = "# disabled\n"; };
  environment.etc."sysctl.d/50-default.conf" = lib.mkForce { text = "# diasbled\n"; };
  environment.etc."sysctl.d/50-coredump.conf" = lib.mkForce { text = "# disabled\n"; };
  boot.kernel.sysctl = lib.mkForce { };
}