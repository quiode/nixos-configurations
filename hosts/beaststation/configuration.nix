# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkForce;
in {
  # specify agenix secrets. will be mounted at /run/agenix/secret
  age.secrets = {
    # password for mail
    beaststation_mail_password.file = ../../secrets/beaststation_mail_password.age;

    # wireguard hub private key (see hermes + hades peers below)
    beaststation_wireguard_key.file = ../../secrets/beaststation_wireguard_key.age;
  };

  # WireGuard hub: site-to-site to hermes (Buttikon LAN) + road-warrior peers (e.g. hades).
  networking.wg-quick.interfaces.wg0 = {
    address = ["10.100.0.1/24"];
    listenPort = 51820;
    privateKeyFile = config.age.secrets.beaststation_wireguard_key.path;
    peers = [
      {
        # hermes: site-to-site.
        publicKey = "PbdcQV8jYWqxpYah0ci/Z71t69OCLIfzJGUTBOGuKRw=";
        # hermes's tunnel IP plus the whole Buttikon LAN, so beaststation
        # routes Zurich-LAN traffic destined for Buttikon through the
        # tunnel, and accepts packets sourced from anywhere in the Buttikon
        # LAN via this peer.
        allowedIPs = ["10.100.0.2/32" "192.168.0.0/24"];
      }
      {
        # hades: road-warrior client. Not Nix/agenix-managed (no SSH host
        # key on hades, and quio's personal key is passphrase-protected).
        # It's a NetworkManager profile instead, backed up in
        # secrets/hades_wireguard_key.age. See secrets/README.md.
        publicKey = "PYuFpM2lJpvZnA0AdeXPYqmTNs0vsX5175PqhymdayY=";
        allowedIPs = ["10.100.0.3/32"];
      }
    ];
  };

  environment = {
    # packages
    systemPackages = with pkgs; [
      sanoid
      immich-cli
      speedtest-cli
      pciutils
      usbutils
    ];

    # custom /etc stuff
    etc = {
      # mail aliases
      aliases = {
        text = ''
          root: mail@dominik-schwaiger.ch
        '';
      };
    };
  };

  modules = {
    services = {
      zfs = {
        enable = true;
        pools = ["virt" "hdd"];
      };

      nvidia = {
        enable = true;
        branch = "legacy_580"; # GTX 1050 Ti (Pascal)
      };

      docker = {
        enable = true;
        deletionFrequency = "daily";
      };
    };

    users = {
      domina = {
        enable = true;
        main = true;
      };

      main = ["root"]; # make root also a main user so all the default configs also apply to him

      vali.enable = true;
      virt.enable = true;
    };
  };

  # Use the grub EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = mkForce false; # disable systemd boot (comes from common config)
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        configurationLimit = 10;
        mirroredBoots = [
          {
            devices = ["/dev/disk/by-id/nvme-CT500P3SSD8_24304A25BBDC-part1"];
            path = "/boot-fallback";
          }
        ];
      };
    };

    kernelModules = [
      # enable remote unlocking by ssh, so that zfs datasets can be encrypted on boot
      "r8169"
      # Modules needed for wireguard
      "wireguard"
      "iptable_nat"
      "ip6table_nat"
      "iptable_filter"
      "ip6table_filter"
    ];
    # enable remote unlocking by ssh, so that zfs datasets can be encrypted on boot
    kernelParams = ["ip=dhcp"];

    initrd = {
      availableKernelModules = ["r8169"];

      systemd = {
        enable = true;
        # Write the ZFS unlock command to root's profile so it runs automatically
        # when an admin SSHs in during boot; killall zfs unblocks systemd's wait
        services.zfs-setup-unlock = {
          wantedBy = ["initrd.target"];
          before = ["initrd.target"];
          unitConfig.DefaultDependencies = false;
          script = ''
            echo "zpool import -a && zfs load-key -a && killall zfs" >> /root/.profile
          '';
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
        };
      };

      network = {
        enable = true;

        # should be the same settings as the normal ssh configuration
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt4xvNKr0MsKk7qY9RJux9KGfUk2lCsnAeUO4NtJP8n quio@artemis"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU+TustXXTKC67YrMyTHsrw2w0IGx1DSA/0woBXJbGg quio@hades"
            "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBL/+jpXlMFM8n4BqvAiPKshuQlHnEkwowrYjq9EExLzrCGpY8D47lAQYh/YkiwILYPHEiznfP7bLCvVifwp1QKI= quio@OnePlusNord"
          ];
          hostKeys = [
            /etc/secrets/initrd/ssh_host_rsa_key
            /etc/secrets/initrd/ssh_host_ed25519_key
          ]; # important: unquoted
        };
      };

      secrets."/config/secrets/passphrase.txt" = /config/secrets/passphrase.txt;
    };
  };

  # Set hostname
  networking = {
    hostId = "d7f38611";

    # enable firewall
    firewall = let
      commonPorts = [
        2222 # ssh
      ];
    in {
      enable = true;

      allowedTCPPorts = commonPorts;
      allowedUDPPorts = commonPorts ++ [51820]; # 51820: wireguard hub

      checkReversePath = false; # needed once asymmetric routing via wg0 exists

      # Docker sets the FORWARD chain's default policy to DROP, which would
      # silently block traffic routed in from Zurich-LAN devices or out to
      # the internet for hades. Test from another device, not beaststation
      # itself: its own traffic skips FORWARD entirely.
      #
      # IFACE is resolved at firewall-start time instead of hardcoded, since
      # beaststation only has one NIC and it's moving to a new network.
      extraCommands = ''
        IFACE=$(ip -4 route show default | awk '{print $5; exit}')
        iptables -A FORWARD -i wg0 -o "$IFACE" -j ACCEPT
        iptables -A FORWARD -i "$IFACE" -o wg0 -j ACCEPT
        # spoke-to-spoke: lets hades (road-warrior) reach the Buttikon LAN
        # through hermes, and vice versa. Both directions use wg0 on both
        # sides, so the rules above don't cover this.
        iptables -A FORWARD -i wg0 -o wg0 -j ACCEPT
        # NAT hades's traffic so it can reach the internet. Scoped to just
        # hades's /32 so it never applies to hermes/Buttikon-LAN traffic.
        iptables -t nat -A POSTROUTING -s 10.100.0.3/32 -o "$IFACE" -j MASQUERADE
      '';
      extraStopCommands = ''
        IFACE=$(ip -4 route show default | awk '{print $5; exit}')
        iptables -D FORWARD -i wg0 -o "$IFACE" -j ACCEPT || true
        iptables -D FORWARD -i "$IFACE" -o wg0 -j ACCEPT || true
        iptables -D FORWARD -i wg0 -o wg0 -j ACCEPT || true
        iptables -t nat -D POSTROUTING -s 10.100.0.3/32 -o "$IFACE" -j MASQUERADE || true
      '';
    };

    # explicitly enable, needed for remote unlocking
    useDHCP = mkForce true;
  };

  # let beaststation route/forward between the LAN, the WAN, and wg0
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

  services = {
    xserver = {
      enable = false; # disable graphics
    };

    # this setups a SSH server
    openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };

      # use non-default 2222 port for ssh
      ports = [2222];
    };

    zfs = {
      # enable zed -> email notifications for zfs
      zed = {
        settings = {
          ZED_DEBUG_LOG = "/tmp/zed.debug.log";
          ZED_EMAIL_ADDR = ["root"];
          ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
          ZED_EMAIL_OPTS = "@ADDRESS@";

          ZED_NOTIFY_INTERVAL_SECS = 3600;
          ZED_NOTIFY_VERBOSE = true;

          ZED_USE_ENCLOSURE_LEDS = true;
          ZED_SCRUB_AFTER_RESILVER = true;
        };

        # this option does not work; will return error
        enableMail = false;
      };
    };

    # automatic snapshots of zfs datasets
    sanoid = {
      enable = true;

      templates = {
        critical = {
          # frequency
          hourly = 36;
          daily = 30;
          monthly = 6;
          yearly = 0;

          # additional settings
          autoprune = true;
          autosnap = true;
        };

        non-critical = {
          # frequency
          hourly = 10;
          daily = 7;
          monthly = 1;
          yearly = 0;

          # additional settings
          autoprune = true;
          autosnap = true;
        };
      };

      datasets = let
        critical = {
          use_template = ["critical"];
          recursive = true;
        };
        non-critical = {
          use_template = ["non-critical"];
          recursive = true;
        };
      in {
        "hdd/enc/critical" = critical;
        "hdd/enc/non-critical" = non-critical;
        "rpool/ssd/critical" = critical;
        "rpool/ssd/non-critical" = non-critical;
        "rpool/home" = critical;
        "rpool/root" = non-critical;
      };
    };

    # automatic backup of zfs snapshots
    syncoid = {
      enable = true;

      user = "syncoid";
      group = "syncoid";

      # use custom ssh key
      sshKey = /etc/secrets/syncoid/id_ed25519;

      commonArgs = [
        "--delete-target-snapshots"
        "--no-sync-snap"
      ];

      commands = {
        "hdd/enc/critical" = {
          source = "hdd/enc/critical";
          target = "domi@yniederer.ch:data/backup/hdd";
          sendOptions = "w";
          extraArgs = [
            "--sshport"
            "2222"
          ];
          recursive = true;
        };

        "rpool/ssd/critical" = {
          source = "rpool/ssd/critical";
          target = "domi@yniederer.ch:data/backup/ssd";
          sendOptions = "w";
          extraArgs = [
            "--sshport"
            "2222"
          ];
          recursive = true;
        };
      };
    };
  };

  # programs
  programs = {
    git = {
      enable = true;
      config = {
        user = {
          email = "server@dominik-schwaiger.ch";
          name = "beaststation";
        };

        save = {
          directory = ["config"];
        };
      };
    };

    # enable mail sending through mail server
    msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = 465;
        tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
        tls = "on";
        auth = "login";
        tls_starttls = "off";
      };
      accounts = {
        default = {
          host = "mail.infomaniak.com";
          from = "server@dominik-schwaiger.ch";
          user = "server@dominik-schwaiger.ch";
          passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.beaststation_mail_password.path}";
        };
      };
    };

    # enable ssh agent
    ssh = {
      startAgent = true;
      knownHosts = {
        "[yniederer.ch]:2222".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMcoq+rOrJaNGZDDupN6mjXHyw5aFA5lY8TedKwfrwmz";
      };
    };
  };
}
