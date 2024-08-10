{ config, pkgs, lib, ... }:
let
  options = import ./options.nix;
  flake = ''
    {
      description = "Container";

      inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        container-base-config.url = "path:/baseconfig";
        user-config.url = "${options.flakeUrl}";
      };

      outputs = { nixpkgs, user-config, container-base-config, ... }@inputs: {
          nixosConfigurations.container = user-config.nixosConfigurations.${options.nixosConfiguration}.extendModules { 
            modules = [container-base-config.nixosModules.containerConfig];
          };
      };
    }
    '';
in {
  system.stateVersion = "24.05";

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  boot.isContainer = true;

  fileSystems."/" =
    { device = "overlay";
      fsType = "overlay";
      noCheck = true;
    };

  fileSystems."/run" =
    { device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=777" ];
    };

  swapDevices = [ ];
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  environment.noXlibs = lib.mkForce true;
  nix.settings.sandbox = false;
  networking.firewall.enable = lib.mkDefault false;
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

  # minimal.nix
  documentation.enable = lib.mkDefault false;
  documentation.doc.enable = lib.mkDefault false;
  documentation.info.enable = lib.mkDefault false;
  documentation.man.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;

  # Perl is a default package.
  environment.defaultPackages = lib.mkDefault [ ];

  environment.stub-ld.enable = false;

  # The lessopen package pulls in Perl.
  programs.less.lessopen = lib.mkDefault null;

  # This pulls in nixos-containers which depends on Perl.
  boot.enableContainers = lib.mkDefault false;

  programs.command-not-found.enable = lib.mkDefault false;

  services.logrotate.enable = lib.mkDefault false;

  services.udisks2.enable = lib.mkDefault false;

  xdg.autostart.enable = lib.mkDefault false;
  xdg.icons.enable = lib.mkDefault false;
  xdg.mime.enable = lib.mkDefault false;
  xdg.sounds.enable = lib.mkDefault false;

  systemd.mounts = [{
    where = "/sys/kernel/debug";
    enable = false;
  }];

  #boot.isContainer = true;
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = false;
  };

  boot.postBootCommands = lib.mkForce "";
  system.activationScripts.specialfs = lib.mkForce "";

  # don't set sycstl values in a container
  #systemd.services.systemd-sysctl.restartTriggers = lib.mkDefault [ ];
  environment.etc."sysctl.d/60-nixos.conf" = lib.mkForce { text = "# disabled\n"; };
  environment.etc."sysctl.d/50-default.conf" = lib.mkForce { text = "# diasbled\n"; };
  environment.etc."sysctl.d/50-coredump.conf" = lib.mkForce { text = "# disabled\n"; };
  # Docker makes this read only
  environment.etc."hosts".enable = false;
  boot.kernel.sysctl = lib.mkForce { "kernel.dmesg_restrict" = 0; };

  systemd.services.create-switch-script = {
    enable = true;
    script = ''
      mkdir -p /build
      echo '${flake}' > /build/flake.nix
      cp /options.nix /baseconfig/options.nix
      /run/current-system/sw/bin/nixos-rebuild switch --flake /build#container
    '';
    wantedBy = [ "multi-user.target" ];
  };
}