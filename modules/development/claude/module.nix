{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib.types) listOf str;
  inherit (pkgs) claude-code;
  cfg = config.modules.development.claude;
in {
  options.modules.development.claude.enable = mkEnableOption "Enable Packages and Settings for working with Claude";
  options.modules.development.claude.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      claude-code
      pkgs.claude-monitor
      pkgs.gh # often used by claude to work with git (instead of using a web fetch)
    ];

    home-manager.users = genAttrs cfg.users (username: {lib, ...}: {
      programs.claude-code = {
        package = claude-code;
        enable = true;
      };
    });
  };
}
