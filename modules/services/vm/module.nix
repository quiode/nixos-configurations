{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  inherit (pkgs) virtiofsd;
  cfg = config.modules.services.vm;
in {
  options.modules.services.vm.enable = mkEnableOption "Virtual Machine";

  config = mkIf cfg.enable {
    virtualisation = {
      # For VM's (Lightroom)
      libvirtd.enable = true;
      spiceUSBRedirection.enable = true;
    };

    environment.systemPackages = [
      virtiofsd # needed for VM's
    ];

    programs.virt-manager.enable = true;
  };
}
