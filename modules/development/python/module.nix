{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.development.python;
in {
  options.modules.development.python.enable = mkEnableOption "Enable Python Toolchain";

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.python3.withPackages
        (python-pkgs:
          with python-pkgs; [
            jupyter
            pandas
            numpy
            matplotlib
            scikit-learn
          ]))
    ];
  };
}
