{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.programs.wireguard;
in {
  options.modules.programs.wireguard.enable = mkEnableOption "Wireguard Client";

  # wireguard should be built-in in gnome so need to install any package
  config = mkIf cfg.enable {
    networking.firewall.checkReversePath = false; # fix for wireguard
  };
}
