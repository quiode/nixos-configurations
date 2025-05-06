# This file is imported in all systems. Only include essential configs.
{
  self,
  pkgs,
  system,
  inputs,
  ...
}: let
  inherit (inputs) nix-vscode-extensions;
in {
  environment.systemPackages = (with pkgs; [wget fastfetch htop alejandra dua btop inputs.agenix.packages."${system}".default rmtrash file imagemagick]) ++ (with self.packages.${pkgs.stdenv.system}; [hello]);

  nixpkgs.
    overlays = [
    # Import all vscode extensions
    nix-vscode-extensions.overlays.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
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

  # Enable networking and firewall
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Set time zone.
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
  system.stateVersion = "24.11"; # Did you read the comment?
}
