{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.users.vali;
in {
  options.modules.users.vali.enable = mkEnableOption "Enable the Vali User";

  config = mkIf cfg.enable {
    users = {
      groups.vali = {};

      users.vali = {
        isNormalUser = true;
        extraGroups = [];
        group = "vali";
        openssh.authorizedKeys.keys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAAWEDj/Yib6Mqs016jx7rtecWpytwfVl28eoHtPYCM9TVLq81VIHJSN37lbkc/JjiXCdIJy2Ta3A3CVV5k3Z37NbgAu23oKA2OcHQNaRTLtqWlcBf9fk9suOkP1A3NzAqzivFpBnZm3ytaXwU8LBJqxOtNqZcFVruO6fZxJtg2uE34mAw=="
        ];
      };
    };

    home-manager.users.vali = {
      home = {
        username = "vali";
        homeDirectory = "/home/vali";
      };
    };
  };
}
