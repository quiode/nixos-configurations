# Contains shared configuration for all systems that are mainly graphical, so laptop, pc, etc.
{
  config,
  pkgs,
  ...
}: {
  modules = {
    boot.plymouth.enable = true;

    bundles.photography.enable = true;

    desktop = {
      enable = true;
      users = config.modules.users.main;
    };

    programs = {
      libreoffice.enable = true;
      localsend.enable = true;
      vscodium = {
        enable = true;
        users = config.modules.users.main;
      };
      wireguard.enable = true;
    };

    services = {
      docker.enable = true;
      vm.enable = true;
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

  environment.systemPackages = with pkgs; [pdfsam-basic];
}
