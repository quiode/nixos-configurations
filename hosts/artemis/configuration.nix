{config, ...}: {
  modules = {
    services = {
      zfs = {
        enable = true;
        pools = ["hdd"];
      };

      nvidia.enable = true;
    };

    bundles.gaming = {
      enable = true;
      users = config.modules.users.main;
    };

    desktop = {
      enable = true;
      users = config.modules.users.main;
    };

    users.quio = {
      enable = true;
      main = true;
    };
  };

  networking.hostId = "0c861852"; # for zfs
}
