{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.users.quio;
in {
  options.modules.users.quio.enable = mkEnableOption "Quio User";

  config = mkIf cfg.enable {
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
  };
}
