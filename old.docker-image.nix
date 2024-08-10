{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/docker-image.nix>
    ./hardware-configuration.nix
  ];

  environment.noXlibs = lib.mkForce false;
  networking.firewall.enable = false;
  networking.hostName = lib.mkForce "";
  networking.interfaces.eth0.useDHCP = false;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.networkmanager.enable = lib.mkForce false;
  #networking.resolvconf.dnsExtensionMechanism = false;
  networking.useDHCP = false;
  networking.wireless.enable = false;
  nix.distributedBuilds = true;
  security.audit.enable = false;
  security.sudo.enable = true;
  systemd.enableEmergencyMode = false;
  systemd.services.console-getty.enable = lib.mkForce false;
  systemd.services.rescue.enable = false;
  systemd.services.systemd-firstboot.enable = lib.mkForce false;
  systemd.services.systemd-hostnamed.enable = lib.mkForce false;

  systemd.mounts = [{
    where = "/sys/kernel/debug";
    enable = false;
  }];

  boot.isContainer = true;
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = false;
  };

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

  environment.variables = { GOROOT = [ "${pkgs.go.out}/share/go" ]; };

  # don't set sycstl values in a container
  systemd.services.systemd-sysctl.restartTriggers = lib.mkForce [ ];
  environment.etc."sysctl.d/60-nixos.conf" = lib.mkForce { text = "# disabled\n"; };
  environment.etc."sysctl.d/50-default.conf" = lib.mkForce { text = "# diasbled\n"; };
  environment.etc."sysctl.d/50-coredump.conf" = lib.mkForce { text = "# disabled\n"; };
  # Docker makes this read only
  environment.etc."hosts".enable = false;
  boot.kernel.sysctl = lib.mkForce { "kernel.dmesg_restrict" = 0; };
}