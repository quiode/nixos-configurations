{
  lib,
  config,
  pkgs,
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
        autoPrune = {
          enable = true;
          flags = ["--all"];
        };

        # manually set container ip-ranges to avoid conflict
        daemon.settings = {
          "default-address-pools" = [
            {
              "base" = "172.29.0.0/16";
              "size" = 24;
            }
            {
              "base" = "172.30.0.0/16";
              "size" = 24;
            }
            {
              "base" = "172.31.0.0/16";
              "size" = 24;
            }
          ];
        };
      };
    };
  };
}
