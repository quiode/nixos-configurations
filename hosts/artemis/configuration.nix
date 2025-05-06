{config, ...}: {
  modules = {
    services.zfs = {
      enable = true;
      pools     = ["hdd"];
    };

    bundles.gaming = {
      enable = true;
      users = [config.modules.users.main];
    };
  };

  networking.hostId = "0c861852"; # for zfs
}
