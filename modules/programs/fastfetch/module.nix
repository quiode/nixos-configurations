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
              source = "nixos";
            };
            modules = [
              "title"
              "separator"
              "os"
              "host"
              "kernel"
              "uptime"
              "packages"
              "shell"
              "display"
              "de"
              "wm"
              "wmtheme"
              "theme"
              "icons"
              "font"
              "cursor"
              "terminal"
              "terminalfont"
              "cpu"
              "gpu"
              "memory"
              "swap"
              "disk"
              "localip"
              "battery"
              "poweradapter"
              "locale"
              "break"
              "colors"
              "zpool"
            ];
          };
        };
      })
    ];
  };
}
