{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.development.miri;
in {
  options.modules.development.miri.enable = mkEnableOption "Enable Required Packages / Options for Developing Miri";

  config = mkIf cfg.enable {
    programs.nix-ld.enable = true;

    environment.systemPackages = with pkgs; [
      gcc
      gnumake
      rustup
      rustup-toolchain-install-master
    ];
  };
}
