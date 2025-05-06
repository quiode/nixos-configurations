{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  inherit (pkgs) localsend;
  cfg = config.modules.programs.localsend;
in {
  options.modules.programs.localsend.enable = mkEnableOption "Localsend";

  config = mkIf cfg.enable {
    networking.firewall = let
      ports = [53317]; # localsend port
    in {
      allowedTCPPorts = ports;
      allowedUDPPorts = ports;
    };

    environment.systemPackages = [localsend];
  };
}
