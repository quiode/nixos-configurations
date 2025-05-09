{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.users.domina;
in {
  options.modules.users.domina.enable = mkEnableOption "Enable the Domina User";
  options.modules.users.domina.main = mkEnableOption "Set to true if domina is the main user of the system";

  config = mkIf cfg.enable {
    modules.users.main = mkIf cfg.main ["domina"];

    users = {
      groups.domina = {};

      users.domina = {
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINt4xvNKr0MsKk7qY9RJux9KGfUk2lCsnAeUO4NtJP8n quio@artemis"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIU+TustXXTKC67YrMyTHsrw2w0IGx1DSA/0woBXJbGg quio@hades"
          "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBL/+jpXlMFM8n4BqvAiPKshuQlHnEkwowrYjq9EExLzrCGpY8D47lAQYh/YkiwILYPHEiznfP7bLCvVifwp1QKI= quio@OnePlusNord"
        ];
        # doing groups here as having the groups without the service/module is not a problem and makes management easier
        extraGroups = [
          "wheel"
          "docker"
          "video"
        ];
        group = "domina";
      };
    };

    home-manager.users.domina = {
      home = {
        username = "domina";
        homeDirectory = "/home/domina";
      };
    };
  };
}
