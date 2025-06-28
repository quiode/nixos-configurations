{
  lib,
  config,
  pkgs,
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
    programs.nvf = {
      enable = false; # TODO: enable when fixed
      enableManpages = true;
    };

    home-manager.users = genAttrs cfg.users (username: {
      programs.nvf = {
        enable = false; # TODO: enable when fixed
        defaultEditor = true;
        enableManpages = true;

        settings = {
          vim = {
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

            languages = {
              enableFormat = true;
              enableTreesitter = true;

              nix = {
                enable = true;

                format = {
                  enable = true;
                  package = pkgs.alejandra;
                  type = "alejandra";
                };

                lsp = {
                  enable = true;
                  package = pkgs.nil;
                  server = "nil";
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
                treesitter.autotagHtml = true;
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
              enable = true;
              context.enable = true;
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
