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
      desktop.${cfg.manager} = {
        enable = true;
        users = cfg.users;
      };
      programs = {
        vscodium.enable = true;
      };
    };

    environment.systemPackages = with pkgs; [spotify nextcloud-client thunderbird immich-cli signal-desktop qbittorrent];

    hardware = {
      pulseaudio.enable = false;

      graphics = {
        enable = true;
        enable32Bit = true; # fixes at-least steam on laptop
      };

      enableAllFirmware = true;
    };

    security.rtkit.enable = true; # Whether to enable the RealtimeKit system service, which hands out realtime scheduling priority to user processes on demand. For example, PulseAudio and PipeWire use this to acquire realtime priority.

    services.pipewire = {
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

    programs.firefox.enable = true;

    home-manager = genAttrs cfg.users (username: {
      services = {
        nextcloud-client = {
          enable = true;
          startInBackground = true;
        };
      };
    });
  };
}
