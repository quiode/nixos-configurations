{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib.types) listOf str;
  inherit (pkgs) zfs-prune-snapshots;
  cfg = config.modules.services.zfs;
in {
  options.modules.services.zfs.enable = mkEnableOption "enable ZFS";
  options.modules.services.zfs.pools = mkOption {
    default = [];
    example = ["hdd"];
    type = listOf str;
    description = "Additional ZFS pools not in the hardware configuration";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [zfs-prune-snapshots];

    boot = {
      supportedFilesystems = ["zfs"];

      zfs = {
        extraPools = cfg.pools;
      };
    };

    services = {
      zfs = {
        trim.enable = true;
        autoScrub.enable = true;
      };
    };
  };
}
