{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  inherit (pkgs) fastfetch;
  cfg = config.modules.programs.fastfetch;
  files = {
    beaststation = ./beaststation.txt;
    artemis = ./artemis.txt;
    hades = ./hades.txt;
  };
in {
  options.modules.programs.fastfetch.enable = mkEnableOption "enable fastfetch";

  config = mkIf cfg.enable {
    environment.systemPackages = [fastfetch];

    environment.interactiveShellInit = ''fastfetch'';

    # force all users to have the same fastfetch settings
    home-manager.sharedModules = [
      (_: {
        programs.fastfetch = {
          enable = true;
          package = fastfetch;

          settings = {
            logo = {
              type = "auto";
              source = files.${config.networking.hostName};

              color = {
                "1" = "red";
                "2" = "blue";
                "3" = "cyan";
              };

              padding = {
                top = 1;
                left = 1;
              };
            };

            modules = [
              "title"
              "separator"
              "os"
              "host"
              "kernel"
              "bios"
              "initsystem"
              "uptime"
              "packages"
              "shell"
              "display"
              "de"
              "wm"
              "terminal"
              "cpu"
              "gpu"
              "memory"
              "swap"
              "disk"
              "zpool"
              "wifi"
              "localip"
              "publicip"
              "bluetooth"
              "battery"
              "poweradapter"
              "locale"
              "break"
              "colors"
            ];
          };
        };
      })
    ];
  };
}
