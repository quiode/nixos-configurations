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

    # wireguard site-to-site key, dials out to beaststation
    hermes_wireguard_key.file = ../../secrets/hermes_wireguard_key.age;
  };

  # WireGuard site-to-site tunnel to beaststation (the hub). Uses the legacy
  # `networking.wireguard` module (not wg-quick) for `dynamicEndpointRefreshSeconds`:
  # beaststation's endpoint is a DNS name that can change IP, and wg-quick only
  # resolves `Endpoint=` once at interface bring-up.
  networking.wireguard.interfaces.wg0 = {
    ips = ["10.100.0.2/32"];
    privateKeyFile = config.age.secrets.hermes_wireguard_key.path;
    peers = [
      {
        publicKey = "8FRlQ/czdDqh46A2KFQJf32ngA/boqmnxl+PEDzcbVU=";
        endpoint = "beaststation.dominik-schwaiger.ch:51820";
        dynamicEndpointRefreshSeconds = 60; # re-resolve DNS periodically
        # The whole tunnel pool (not just beaststation's own /32) + the
        # Zurich LAN. hermes needs a route to the pool, not just the hub
        # address, so return traffic to OTHER peers behind the hub (e.g.
        # hades at 10.100.0.3, reaching the Buttikon LAN through beaststation)
        # has somewhere to go.
        allowedIPs = ["10.100.0.0/24" "192.168.1.0/24"];
        persistentKeepalive = 25; # keep hermes's NAT mapping alive from the Buttikon side
      }
    ];
  };

  networking.firewall = {
    checkReversePath = false;
    # hermes has no Docker, so FORWARD's default policy is ACCEPT and
    # traffic would pass anyway, but add explicit rules for clarity/robustness.
    # The interface is resolved at firewall-start time rather than hardcoded,
    # since hermes only has one physical NIC.
    extraCommands = ''
      IFACE=$(ip -4 route show default | awk '{print $5; exit}')
      iptables -A FORWARD -i wg0 -o "$IFACE" -j ACCEPT
      iptables -A FORWARD -i "$IFACE" -o wg0 -j ACCEPT
    '';
    extraStopCommands = ''
      IFACE=$(ip -4 route show default | awk '{print $5; exit}')
      iptables -D FORWARD -i wg0 -o "$IFACE" -j ACCEPT || true
      iptables -D FORWARD -i "$IFACE" -o wg0 -j ACCEPT || true
    '';
  };
  # No allowedUDPPorts needed, hermes only dials out. The NixOS firewall
  # tracks the resulting UDP flow as established for return traffic.

  # let hermes route/forward between the Buttikon LAN and wg0
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

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
