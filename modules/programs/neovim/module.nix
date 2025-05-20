{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs) vimPlugins;
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
    programs.neovim.enable = true;

    home-manager.users = genAttrs cfg.users (username: {
      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        defaultEditor = true;

        extraLuaConfig = ''
          vim.o.number = true
          vim.o.wrap = false
          vim.o.tabstop = 2
          vim.o.shiftwidth = 2
          vim.o.smartcase = true
          vim.o.ignorecase = true
          vim.o.hlsearch = false
          vim.o.signcolumn = 'yes'

          -- Set dracula theme
          vim.cmd.colorscheme('dracula')
        '';

        extraPackages = with pkgs; [tree-sitter];

        plugins = with vimPlugins; [
          dracula-nvim
          {
            plugin = nvim-treesitter;
            config = ''
              -- A list of parser names, or "all" (the listed parsers MUST always be installed)
              ensure_installed = "all,

              -- Install parsers synchronously (only applied to `ensure_installed`)
              sync_install = true,

              -- Automatically install missing parsers when entering buffer
              -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
              auto_install = true,
            '';
          }
        ];
      };
    });
  };
}
