{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib) types;
  cfg = config.modules.services.docker;
in {
  options.modules.services.docker.enable = mkEnableOption "Docker";
  options.modules.services.docker.deletionFrequency = mkOption {
    default = "weekly";
    type = types.str;
    description = ''
      Specification (in the format described by
      {manpage}`systemd.time(7)`) of the time at
      which the automatic docker prune will occur.
    '';
  };

  config = mkIf cfg.enable {
    virtualisation = {
      docker = {
        enable = true;
        autoPrune = {
          enable = true;
          randomizedDelaySec = "1h";
          dates = cfg.deletionFrequency;
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
