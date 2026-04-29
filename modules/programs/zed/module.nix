{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) genAttrs types;
  inherit (types) listOf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.programs.zed;
in {
  options.modules.programs.zed.enable = mkEnableOption "Zed Editor";
  options.modules.programs.zed.difftool = mkOption {
    type = types.bool;
    default = true;
    description = "Use zed as diff tool in git";
  };
  options.modules.programs.zed.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf types.str;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [pkgs.zed-editor];

    # use zed as diff tool in git
    programs.git.config = mkIf cfg.difftool {
      diff.tool = "zeditor";
      difftool.zeditor.cmd = "zeditor --wait --diff $LOCAL $REMOTE";
    };

    home-manager.users = genAttrs cfg.users (username: {
      programs.zed-editor = {
        enable = true;
        extensions = ["nix" "catppuccin" "catppuccin-icons" "toml" "java" "dockerfile" "typst" "make" "gitlab-ci-ls"];
        extraPackages = [pkgs.gitlab-ci-ls];
        mutableUserSettings = false;
        mutableUserDebug = false;
        mutableUserKeymaps = false;
        mutableUserTasks = false;
        userSettings = {
          vim_mode = true;
          auto_update = false;
          base_keymap = "VSCode";
          autosave = "on_focus_change";
          terminal = {
            shell = {
              program = "zsh";
            };
          };

          tabs = {
            file_icons = true;
            git_status = true;
            show_diagnostics = "errors";
          };

          theme = {
            mode = "system";
            light = "Catppuccin Latte";
            dark = "Catppuccin Mocha";
          };

          icon_theme = {
            mode = "system";
            light = "Catppuccin Latte";
            dark = "Catppuccin Mocha";
          };

          lsp = {
            yaml-language-server = {
              settings = {
                yaml = {
                  customTags = ["!reference sequence"];
                };
              };
            };
            rust-analyzer = {
              initialization_options = {
                check = {
                  command = "clippy";
                };
              };
            };
            nil = {
              initialization_options = {
                autoArchive = true;
                formatting = {
                  command = ["alejandra" "--quiet" "--"];
                };
              };
            };
          };

          languages = {
            Nix = {
              language_servers = ["nil" "!nixd"];
            };
          };

          language_models = {
            openai_compatible = {
              # TODO: finish setup, save TOKEN in local dotenv
              sph = {
                api_url = "https://litellm.sph-prod.ethz.ch/v1";
                available_models = [];
              };
            };
          };
        };
      };
    });
  };
}
