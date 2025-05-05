{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.services.docker;
in {
  options.modules.services.docker.enable = mkEnableOption "Docker";

  config = mkIf cfg.enable {
    virtualisation = {
      docker = {
        enable = true;
        autoPrune.enable = true;
      };
    };
  };
}
