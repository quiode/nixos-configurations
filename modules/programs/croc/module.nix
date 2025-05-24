{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs) croc;
  inherit (lib) genAttrs;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.programs.croc;
in {
  options.modules.programs.croc.enable = mkEnableOption "Enable croc";
  options.modules.programs.croc.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [croc];

    home-manager.users = genAttrs cfg.users (username: {config, ...}: {
      home.shellAliases = {
        croc = ''croc --relay "croc.dominik-schwaiger.ch"'';
      };
    });
  };
}
