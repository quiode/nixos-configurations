{
  lib,
  config,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.services.atuin;
in {
  options.modules.services.atuin.enable = mkEnableOption "Enable Atuin";
  options.modules.services.atuin.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    home-manager.users = genAttrs cfg.users (username: {
      programs = {
        atuin = {
          enable = true;
          # daemon.enable = true; # is currently unstable
          settings = {
            dialect = "uk";
            auto_sync = true;
            sync_frequency = "5m";
            sync_address = "https://atuin.dominik-schwaiger.ch";
          };
        };
      };
    });
  };
}
