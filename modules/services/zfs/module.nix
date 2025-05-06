{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) filterAttrs last sort versionOlder;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  inherit (lib.types) listOf str;
  inherit (pkgs) linuxKernel zfs-prune-snapshots;
  cfg = config.modules.services.zfs;
  latestKernelPackage = let
    zfsCompatibleKernelPackages =
      filterAttrs (
        name: kernelPackages:
          (builtins.match "linux_[0-9]+_[0-9]+" name)
          != null
          && (builtins.tryEval kernelPackages).success
          && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
      )
      linuxKernel.packages;
  in
    last (
      sort (a: b: (versionOlder a.kernel.version b.kernel.version)) (
        builtins.attrValues zfsCompatibleKernelPackages
      )
    );
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

      # use the latest ZFS-compatible Kernel
      # Note this might jump back and forth as kernels are added or removed.
      kernelPackages = latestKernelPackage;
    };

    services = {
      zfs = {
        trim.enable = true;
        autoScrub.enable = true;
      };
    };
  };
}
