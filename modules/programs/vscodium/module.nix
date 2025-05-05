{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  inherit (pkgs) vscodium nil;
  inherit (inputs) nix-vscode-extensions;
  cfg = config.modules.programs.vscodium;
in {
  options.modules.programs.vscodium.enable = mkEnableOption "VSCodium";

  config = mkIf cfg.enable {
    environment.systemPackages = [vscodium nil];
  };

  nixpkgs.
    overlays = [
    # Import all vscode extensions
    nix-vscode-extensions.overlays.default
  ];
}
