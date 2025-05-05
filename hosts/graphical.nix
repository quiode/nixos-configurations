# Contains shared configuration for all systems that are mainly graphical, so laptop, pc, etc.
_: let
  admins = ["quio"];
in {
  modules = {
    boot.plymouth.enable = true;

    bundles.photography.enable = true;

    desktop = {
      enable = true;
      users = admins;
    };

    programs = {
      libreoffice.enable = true;
      localsend.enable = true;
      vscodium.enable = true;
      wireguard.enable = true;
    };

    services = {
      docker.enable = true;
      vm.enable = true;
    };

    users.quio.enable = true;
  };
}
