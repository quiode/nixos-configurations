{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.development.rust;
in {
  options.modules.development.rust.enable = mkEnableOption "Enable Rust Toolchain";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [gcc rustup jetbrains.rust-rover];
  };
}
