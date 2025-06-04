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

      nvidia.enable = true;

      docker.enable = true;
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
      # Modules needed for wireguard / wg-easy
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
      network = {
        enable = true;
        postCommands = ''
          # Import all pools and Add the load-key command to the .profile
          echo "zpool import -a && zfs load-key -a && killall zfs" >> /root/.profile
        '';

        # should be the same settings as the normal ssh configuration
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt4xvNKr0MsKk7qY9RJux9KGfUk2lCsnAeUO4NtJP8n quio@gaming-pc"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU+TustXXTKC67YrMyTHsrw2w0IGx1DSA/0woBXJbGg quio@laptop"
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
      allowedUDPPorts = commonPorts;
    };

    # explicitly enable, needed for remote unlocking
    useDHCP = mkForce true;
  };

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
        "rpool/nix" = non-critical;
        "rpool/root" = non-critical;
        "rpool/var" = non-critical;
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
          target = "domina@yniederer.ch:backup/hdd";
          sendOptions = "w";
          extraArgs = [
            "--sshport"
            "2222"
          ];
          recursive = true;
        };

        "rpool/ssd/critical" = {
          source = "rpool/ssd/critical";
          target = "domina@yniederer.ch:backup/ssd";
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
          email = "beaststation@dominik-schwaiger.ch";
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
          host = "mail.dominik-schwaiger.ch";
          from = "beaststation@dominik-schwaiger.ch";
          user = "beaststation@dominik-schwaiger.ch";
          passwordeval = "${pkgs.coreutils}/bin/cat ${config.age.secrets.beaststation_mail_password.path}";
        };
      };
    };

    # enable ssh agent
    ssh = {
      startAgent = true;
      knownHosts = {
        "[yniederer.ch]:2222".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxx2JxRobdvqPUIDgl0xFHoF0UVjNGNGmQzqg0xr210";
      };
    };
  };
}
