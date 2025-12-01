{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.desktop;
in {
  options.modules.desktop = {
    enable = mkEnableOption "Desktop";
    manager = mkOption {
      type = str;
      default = "gnome";
      description = "The wm, de, etc. to use. Has to be an existing option under `desktop`.";
    };
    users = mkOption {
      example = "[quio, domina, ...]";
      description = "The user for which a home manager configuration should be created.";
      type = listOf str;
    };
  };

  config = mkIf cfg.enable {
    modules = {
      bundles.photography.enable = true;

      # TODO: make more generic
      desktop.gnome = mkIf (cfg.manager == "gnome") {
        enable = true;
        users = cfg.users;
      };

      programs = {
        vscodium = {
          enable = true;
          users = config.modules.users.main;
        };

        libreoffice.enable = true;
        localsend.enable = true;
        wireguard.enable = true;
      };

      services = {
        vm.enable = true;
        docker.enable = true;
        printing.enable = true;
      };

      boot.plymouth.enable = true;
    };

    environment.systemPackages = with pkgs; [
      spotify
      nextcloud-client
      thunderbird
      immich-cli
      signal-desktop
      qbittorrent
      pdfsam-basic
      marktext # TODO: create home-manager module or somehow manage settings
    ];

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true; # fixes at-least steam on laptop
      };

      enableAllFirmware = true;
    };

    security.rtkit.enable = true; # Whether to enable the RealtimeKit system service, which hands out realtime scheduling priority to user processes on demand. For example, PulseAudio and PipeWire use this to acquire realtime priority.

    services = {
      pulseaudio.enable = false;

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
    };

    programs.firefox.enable = true;

    networking.networkmanager.enable = true;

    home-manager.users = genAttrs cfg.users (username: {
      services = {
        nextcloud-client = {
          enable = true;
          startInBackground = true;
        };
      };
    });
  };
}
