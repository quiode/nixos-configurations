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
    hades = ./beaststation.png;
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
          settings = {
            logo = {
              type = "chafa";
              source = files.${config.networking.hostName};
              chafa = {
                canvasMode = "INDEXED_8";
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
