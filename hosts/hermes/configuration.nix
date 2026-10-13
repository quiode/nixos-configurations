# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkForce;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # specify agenix secrets. will be mounted at /run/agenix/secret
  age.secrets = {
    # password for mail
    hermes_infomaniak_dyndns.file = ../../secrets/hermes_infomaniak_dyndns.age;
  };

  boot.loader = {
    # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
    grub.enable = mkForce false;

    # disable systemd boot (comes from common config)
    systemd-boot.enable = mkForce false;

    # Enables the generation of /boot/extlinux/extlinux.conf
    generic-extlinux-compatible.enable = true;
  };

  networking.hostName = "hermes";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  modules.users = {
    domina = {
      enable = true;
      main = true;
    };

    main = ["root"]; # make root also a main user so all the default configs also apply to him
  };

  # this setups a SSH server
  services = {
    xserver = {
      enable = false; # disable graphics
    };

    openssh = {
      enable = true;
      ports = [22 2223];
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };

    # automatically update ip
    ddclient = {
      enable = true;
      interval = "5min";
      protocol = "dyndns2";
      username = "hermes";
      passwordFile = config.age.secrets.hermes_infomaniak_dyndns.path;
      domains = ["hermes.dominik-schwaiger.ch"];
      server = "infomaniak.com";
      ssl = true;
    };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = mkForce "26.05"; # Did you read the comment?
}
