# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  nix-vscode-extensions,
  ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  # Bootloader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    zfs = {
      extraPools = [ "hdd" ];
    };

    # use the latest ZFS-compatible Kernel
    # Note this might jump back and forth as kernels are added or removed.
    kernelPackages = latestKernelPackage;
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Enable the X11 windowing system.
  services = {
    xserver = {
      enable = true;

      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "ch";
        variant = "";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    zfs.autoScrub.enable = true;
  };

  # Configure console keymap
  console.keyMap = "sg";

  hardware = {
    pulseaudio.enable = false;

    graphics.enable = true;
    nvidia = {

      # Modesetting is required.
      modesetting.enable = true;

      # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
      # Enable this if you have graphical corruption issues or application crashes after waking
      # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
      # of just the bare essentials.
      powerManagement.enable = false;

      # Fine-grained power management. Turns off GPU when not in use.
      # Experimental and only works on modern Nvidia GPUs (Turing or newer).
      powerManagement.finegrained = false;

      # Use the NVidia open source kernel module (not to be confused with the
      # independent third-party "nouveau" open source driver).
      # Support is limited to the Turing and later architectures. Full list of
      # supported GPUs is at:
      # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
      # Only available from driver 515.43.04+
      open = false;

      # Enable the Nvidia settings menu,
      # accessible via `nvidia-settings`.
      nvidiaSettings = true;

      # Optionally, you may need to select the appropriate driver version for your specific GPU.
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

  };

  security.rtkit.enable = true;

  users = {
    groups.quio = { };

    users.quio = {
      isNormalUser = true;
      description = "Dominik Schwaiger";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      group = "quio";
    };
  };

  programs = {
    firefox.enable = true;
    gnupg.agent.enable = true;
    git = {
      enable = true;
    };
    vim = {
      enable = true;
      defaultEditor = true;
    };
    bash = {
      # set alias for simple update
      shellAliases = {
        update = "nix flake update --commit-lock-file --flake /config";
        upgrade = "nh os switch /config";
      };

      loginShellInit = ''
        # If not running interactively, don't do anything and return early
        [[ $- == *i* ]] || return  
        fastfetch
      '';
    };
    nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 7d --keep 5";
      flake = "/config";
    };
  };

  # Allow unfree packages
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      nix-vscode-extensions.overlays.default
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      vscodium
      wget
      fastfetch
      htop
      nixfmt-rfc-style
      nil
      gnome-tweaks
    ];

    gnome.excludePackages = with pkgs; [
      gnome-photos
      gnome-tour
      gedit # text editor
      cheese # webcam tool
      gnome-music
      epiphany # web browser
      geary # email reader
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # Help view
      gnome-contacts
      gnome-initial-setup
      gnome-maps
    ];
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
