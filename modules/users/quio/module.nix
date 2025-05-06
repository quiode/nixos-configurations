{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.users.quio;
in {
  options.modules.users.quio.enable = mkEnableOption "Enable the Quio User";
  options.modules.users.quio.main = mkEnableOption "Set to true if quio is the main user of the system";

  config = mkIf cfg.enable {
    modules.users.main = mkIf cfg.main "quio";

    users = {
      groups.quio = {};

      users.quio = {
        isNormalUser = true;
        description = "Dominik Schwaiger";
        # doing groups here as having the groups without the service/module is not a problem and makes management easier
        extraGroups = [
          "networkmanager"
          "wheel"
          "camera" # needed to access camera
          "docker"
          "libvirtd" # access to virtual machines
        ];
        group = "quio";
      };
    };

    home-manager.users.quio = {
      home = {
        username = "quio";
        homeDirectory = "/home/quio";
      };

      programs = {
        git = {
          enable = true;
          userName = "Dominik Schwaiger";
          userEmail = "mail@dominik-schwaiger.ch";
          signing = {
            signByDefault = true;
            key = "D9FE 655C CD52 8F80 3D27 8F75 F7E7 E19B C69F 7DF5";
          };
          extraConfig = {
            pull.rebase = true;
            push.autoSetupRemote = true;
          };
        };

        ssh = {
          enable = true;
          matchBlocks = {
            home = {
              hostname = "dominik-schwaiger.ch";
              port = 2222;
              user = "domina";
            };

            home-root = {
              hostname = "dominik-schwaiger.ch";
              port = 2222;
              user = "root";
            };

            backup = {
              hostname = "yniederer.ch";
              port = 2222;
              user = "domina";
            };
          };
        };
      };
    };
  };
}
