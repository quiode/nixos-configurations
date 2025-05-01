# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.initrd.luks.devices."luks-e33fcdd4-9e85-413e-bd46-6f141716d32a".device = "/dev/disk/by-uuid/e33fcdd4-9e85-413e-bd46-6f141716d32a";
  networking = {
    hostName = "laptop"; # Define your hostname.
  };

  environment.systemPackages = with pkgs; [
    xournalpp
  ];
}
