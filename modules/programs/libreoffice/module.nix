{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  inherit (pkgs) libreoffice-qt hunspell hunspellDicts;
  cfg = config.modules.programs.libreoffice;
in {
  options.modules.programs.libreoffice.enable = mkEnableOption "Libreoffice";

  config = mkIf cfg.enable {
    environment.systemPackages =
      [libreoffice-qt hunspell]
      ++ (with hunspellDicts; [
        en-gb-large
        de-ch
        fr-any
      ]);
  };
}
