# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  lib,
  config,
  pkgs,
  ...
}:
let
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "gaming-pc"; # Define your hostname.
    hostId = "0c861852"; # for zfs
  };

  programs = {
    steam.enable = true;
  };

  boot = {
    supportedFilesystems = [ "zfs" ];

    zfs = {
      extraPools = [ "hdd" ];
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

  environment.systemPackages = with pkgs; [
    vesktop
  ];
}
