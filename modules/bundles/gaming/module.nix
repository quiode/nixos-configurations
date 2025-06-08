# Contains all applications needed to edit photos
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
  cfg = config.modules.bundles.gaming;
in {
  options.modules.bundles.gaming.enable = mkEnableOption "enable different launchers, etc. for gaming";
  options.modules.bundles.gaming.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;

    # steam ports for local file sharing
    networking.firewall = {
      allowedTCPPorts = [27040];
      allowedUDPPortRanges = [
        {
          from = 27031;
          to = 27036;
        }
      ];
    };

    environment.systemPackages = with pkgs; [
      vesktop
      prismlauncher # for minecraft
      steam-run # to run steam games manually
    ];

    home-manager.users = genAttrs cfg.users (username: {
      # find values using "dconf watch /"
      dconf.settings = {
        # are at "/run/current-system/sw/share/applications"
        "org/gnome/shell".favorite-apps = [
          "steam.desktop"
          "vesktop.desktop"
        ];
      };
    });
  };
}
