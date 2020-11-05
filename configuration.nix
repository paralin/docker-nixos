{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/docker-image.nix>
    ./hardware-configuration.nix
  ];

  documentation.doc.enable = false;
  environment.noXlibs = lib.mkForce false;
  networking.firewall.enable = false;
  networking.interfaces.eth0.useDHCP = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.networkmanager.enable = lib.mkForce false;
  networking.resolvconf.dnsExtensionMechanism = false;
  networking.useDHCP = false;
  networking.wireless.enable = false;
  nix.distributedBuilds = true;
  security.audit.enable = false;
  security.sudo.enable = true;
  systemd.enableEmergencyMode = false;
  systemd.services.rescue.enable = false;
  systemd.services.systemd-hostnamed.enable = lib.mkForce false;

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
    curl
    git
    gnumake
    gnupg
    htop
    nix
    tmux
    tree
    unzip
    vim
    wget
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

  # add sudo group
  users.groups.sudo = {};
  security.sudo.extraRules = [
    { groups = [ "sudo" ]; commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ]; }
  ];
}