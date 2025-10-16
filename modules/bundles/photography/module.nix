# Contains all applications needed to edit photos
{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.bundles.photography;
in {
  options.modules.bundles.photography.enable = mkEnableOption "Photography Bundle";

  config = mkIf cfg.enable {
    programs.gphoto2.enable = true; # used to access my fujifilm camera

    modules.services.vm.enable = true; # enable vm to install windows for adobe lightroom

    environment.systemPackages = with pkgs; [geeqie identity gimp gthumb photocollage];
  };
}
