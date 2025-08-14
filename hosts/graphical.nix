# Contains shared configuration for all systems that are mainly graphical, so laptop, pc, etc.
{
  config,
  pkgs,
  ...
}: {
  modules = {
    boot.plymouth.enable = true;

    # TODO: merge with graphical as they both are the same?
    desktop = {
      enable = true;
      users = config.modules.users.main;
    };

    programs = {
      localsend.enable = true;
      wireguard.enable = true;
    };

    services = {
      docker.enable = true;
      printing = {
        enable = true;
      };
    };

    users.quio = {
      enable = true;
      main = true;
    };
  };

  networking.networkmanager.enable = true;
}
