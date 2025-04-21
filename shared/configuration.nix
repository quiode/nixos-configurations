# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  pkgs,
  nix-vscode-extensions,
  inputs,
  ...
}:
{
  # Bootloader.
  boot = {
    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = with pkgs; [ nixos-bgrt-plymouth ];
    };

    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    loader = {
      # Hide the OS choice for bootloaders.
      # It's still possible to open the bootloader list by pressing any key
      # It will just not appear on screen unless a key is pressed
      timeout = 0;

      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable networking
  networking = {
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      autoPrune.enable = true;
    };

    # For VM's (Lightroom)
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };

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
  };

  # Configure console keymap
  console.keyMap = "sg";

  hardware = {
    pulseaudio.enable = false;

    graphics.enable = true;

    enableAllFirmware = true;
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
        "camera" # needed to access camera
        "docker"
        "libvirtd" # access to virtual machines
      ];
      group = "quio";
    };
  };

  programs = {
    virt-manager.enable = true;
    firefox.enable = true;
    gnupg.agent.enable = true;
    gphoto2.enable = true; # used to access my fujifilm camera
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
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };

    overlays = [
      nix-vscode-extensions.overlays.default
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages =
      (with pkgs; [
        vscodium
        wget
        fastfetch
        htop
        nixfmt-rfc-style
        nil
        gnome-tweaks
        spotify
        dua
        nextcloud-client
        thunderbird
        btop
        bitwarden-desktop
        inputs.agenix.packages."${system}".default
        immich-cli
        nvtopPackages.full
        identity
        rmtrash
        signal-desktop
        file
        imagemagick
        geeqie
        qbittorrent
        virtiofsd # needed for VM's
      ])
      ++ (with pkgs.gnomeExtensions; [
        tray-icons-reloaded
        removable-drive-menu
        gsconnect
        gravatar
        wallpaper-slideshow
        clipboard-history
      ]);

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
