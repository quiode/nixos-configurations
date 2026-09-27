{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf mkForce;
  cfg = config.modules.development.stm32;
in {
  options.modules.development.stm32.enable = mkEnableOption "Enable Required Packages / Options for Developing STM32 Projects";

  config = mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      libraries = with pkgs; [libusb1];
    };

    modules.programs.vscodium.enable = mkForce false; # my vscodium config does not work with stm32 setup, so just disable

    environment.systemPackages = with pkgs; [
      (vscode.fhsWithPackages (ps:
        with ps; [
          libusb1
          libxrender
          libx11
          libxext
          libxi
          libxtst
          fontconfig
          freetype
          zlib
          zstd
          alsa-lib
          ncurses5
          stdenv.cc.cc.lib
          libxcrypt-legacy
          brotli
        ]))
    ];

    services.udev.packages = with pkgs; [stlink];
  };
}
