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
    modules.users.main = mkIf cfg.main ["quio"];

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

          settings = {
            user = {
              name = "Dominik Schwaiger";
              email = "mail@dominik-schwaiger.ch";
            };

            pull.rebase = true;
            push.autoSetupRemote = true;
            init.defaultBranch = "main";
          };

          signing = {
            signByDefault = true;
            key = "D9FE 655C CD52 8F80 3D27 8F75 F7E7 E19B C69F 7DF5";
          };
        };

        ssh = {
          enable = true;
          enableDefaultConfig = false;
          settings = {
            home = {
              HostName = "dominik-schwaiger.ch";
              Port = 2222;
              User = "domina";
            };

            home-root = {
              HostName = "dominik-schwaiger.ch";
              Port = 2222;
              User = "root";
            };

            backup = {
              HostName = "yniederer.ch";
              Port = 2222;
              User = "domina";
            };

            euler = {
              HostName = "euler.ethz.ch";
              Port = 22;
              User = "dschwaiger";
            };

            vsos = {
              HostName = "dschwaiger.vsos.ethz.ch";
              Port = 22;
              User = "ubuntu";
            };
          };
        };
      };
    };
  };
}
