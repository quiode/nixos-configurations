# This file is imported in all systems. Only include essential configs.
{
  self,
  pkgs,
  inputs,
  config,
  ...
}: let
  inherit (pkgs) lix;
  inherit (inputs) nix-vscode-extensions;
  stateVersion = "24.11";
in {
  environment.systemPackages = (with pkgs; [wget onefetch htop alejandra dua btop inputs.agenix.packages."${system}".default rmtrash file imagemagick zip unzip]) ++ (with self.packages.${pkgs.stdenv.system}; []);

  modules = {
    programs = {
      zsh = {
        enable = true;
        users = [config.modules.users.main];
      };

      fastfetch.enable = true;
    };

    services.atuin = {
      enable = true;
      users = [config.modules.users.main];
    };
  };

  # use lix instead of nix. ask vali why lix is better
  nix.package = lix;

  nixpkgs.
    overlays = [
    # Import all vscode extensions
    nix-vscode-extensions.overlays.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";

    # home manager config for all users
    sharedModules = [
      (_: {
        nixpkgs = {
          config = {
            allowUnfree = true;
            # Workaround for https://github.com/nix-community/home-manager/issues/2942
            allowUnfreePredicate = _: true;
          };
        };

        home.stateVersion = stateVersion;

        programs.home-manager.enable = true;

        # Nicely reload system units when changing configs
        systemd.user.startServices = "sd-switch";
      })
    ];
  };

  boot.loader = {
    # Systemd Boot
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.firewall.enable = true;

  # set time zone
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  services = {
    xserver = {
      # Configure keymap in X11
      xkb = {
        layout = "ch";
        variant = "";
      };
    };
  };

  # Configure console keymap
  console.keyMap = "sg";

  programs = {
    gnupg.agent.enable = true;

    git = {
      enable = true;
    };

    vim = {
      enable = true;
      defaultEditor = true;
    };

    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 5";
      flake = "/config";
    };
  };

  nixpkgs = {
    # Allow unfree packages
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # optimize storage automatically
  nix.optimise.automatic = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = stateVersion; # Did you read the comment?
}
