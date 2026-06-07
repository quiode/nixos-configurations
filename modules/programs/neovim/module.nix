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
  # TODO: re-enable once nvf migrates away from archived nvim-treesitter
  # https://github.com/NotAShelf/nvf/issues/1312
  treesitter = false;
in {
  options.modules.programs.neovim.enable = mkEnableOption "Enable neovim Editor";
  options.modules.programs.neovim.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    programs.nvf = {
      enable = true;
      enableManpages = true;
    };

    home-manager.users = genAttrs cfg.users (username: {
      programs.nvf = {
        enable = true;
        defaultEditor = true;
        enableManpages = true;

        settings = {
          vim = {
            clipboard = {
              enable = true;
              providers.xclip.enable = true;
              registers = "unnamedplus";
            };

            viAlias = true;
            vimAlias = true;

            theme = {
              enable = true;
              name = "catppuccin";
              style = "mocha";
            };

            lsp = {
              formatOnSave = true;
              inlayHints.enable = true;

              # code actions
              lightbulb.enable = true;
            };

            formatter.conform-nvim.enable = true;

            languages = {
              enableFormat = true;
              enableTreesitter = treesitter;

              nix = {
                enable = true;

                format = {
                  enable = true;
                  type = ["alejandra"];
                };

                lsp = {
                  enable = true;
                  servers = ["nil"];
                };
              };

              yaml = {
                enable = true;
                lsp.enable = true;
              };

              markdown = {
                enable = true;
                lsp.enable = true;
                extensions.render-markdown-nvim.enable = true;
              };

              bash = {
                enable = true;
                lsp.enable = true;
              };

              html = {
                enable = true;
                treesitter.autotagHtml = treesitter;
              };

              tailwind = {
                enable = true;
                lsp.enable = true;
              };

              css = {
                enable = true;
                lsp.enable = true;
              };

              ts = {
                enable = true;
                lsp.enable = true;
                extensions.ts-error-translator.enable = true;
              };
            };

            treesitter = {
              enable = treesitter;
              context.enable = treesitter;
            };

            # autocompletion (ctrl + space)
            mini.completion.enable = true;

            # multi-purpose search and picker utility
            # use "<space>ff" to open basic
            telescope.enable = true;
          };
        };
      };
    });
  };
}
