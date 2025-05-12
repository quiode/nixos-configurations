{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs) magic-wormhole;
  inherit (lib) genAttrs;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.programs.wormhole;
in {
  options.modules.programs.wormhole.enable = mkEnableOption "Enable Magic Wormhole";
  options.modules.programs.wormhole.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };
  options.modules.programs.wormhole.relay-url = mkOption {
    example = "ws://relay.wormhole.dominik-schwaiger.ch/v1";
    description = "URL of the relay server";
    type = str;
    default = "ws://relay.wormhole.dominik-schwaiger.ch/v1";
  };
  options.modules.programs.wormhole.transit-helper = mkOption {
    example = "tcp:transit.wormhole.dominik-schwaiger.ch";
    description = "URL of the transit server";
    type = str;
    default = "tcp:transit.wormhole.dominik-schwaiger.ch";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [magic-wormhole];

    home-manager.users = genAttrs cfg.users (username: {
      home.shellAliases = {
        wormhole = "wormhole --relay-url wss://relay.wormhole.dominik-schwaiger.ch/v1 --transit-helper tcp:transit.wormhole.dominik-schwaiger.ch:443";
        wm = "wormhole";
      };
    });
  };
}
