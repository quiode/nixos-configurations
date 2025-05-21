{
  lib,
  config,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.programs.neovim;
in {
  options.modules.programs.neovim.enable = mkEnableOption "Enable neovim Editor";
  options.modules.programs.neovim.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    programs.nvf.enable = true;

    home-manager.users = genAttrs cfg.users (username: {
      programs.nvf = {
        enable = true;
        defaultEditor = true;

        settings = {
          vim = {
            viAlias = true;
            vimAlias = true;

            theme = {
              enable = true;
              name = "catppuccin";
              style = "mocha";
            };
          };
        };
      };
    });
  };
}
