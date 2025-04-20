# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.initrd.luks.devices."luks-cfa0079d-7fc6-4991-b3f8-ec9e31f5bd9f".device =
    "/dev/disk/by-uuid/cfa0079d-7fc6-4991-b3f8-ec9e31f5bd9f";
  networking = {
    hostName = "laptop"; # Define your hostname.
    wireless.enable = true; # Enables wireless support via wpa_supplicant.
  };
}
