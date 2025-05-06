# Contains shared configuration for all systems that are mainly graphical, so laptop, pc, etc.
{config, ...}: {
  modules = {
    boot.plymouth.enable = true;

    bundles.photography.enable = true;

    desktop = {
      enable = true;
      users = config.users.users;
    };

    programs = {
      libreoffice.enable = true;
      localsend.enable = true;
      vscodium = {
        enable = true;
        users = config.users.users;
      };
      wireguard.enable = true;
    };

    services = {
      docker.enable = true;
      vm.enable = true;
    };

    users.quio.enable = true;
  };
}
