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
  inherit (pkgs) vscodium nil nix4vscode;
  cfg = config.modules.programs.vscodium;
  getExtensions = nix4vscode.forVscodeVersion vscodium.version;
in {
  options.modules.programs.vscodium.enable = mkEnableOption "VSCodium";
  options.modules.programs.vscodium.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [vscodium nil];

    home-manager.users = genAttrs cfg.users (username: {
      programs.vscode = {
        enable = true;
        package = vscodium;
        mutableExtensionsDir = false;

        profiles = let
          commonExtensions = getExtensions [
            "vscodevim.vim"
            "ms-azuretools.vscode-containers"
            "esbenp.prettier-vscode"
            "ultram4rine.vscode-choosealicense"
            "tomoki1207.pdf" # pdf viewer
            "streetsidesoftware.code-spell-checker" # spellcheck
            "streetsidesoftware.code-spell-checker-german" # spellcheck - german addon
            "edwinhuish.better-comments-next"
            "catppuccin.catppuccin-vsc"
            "catppuccin.catppuccin-vsc-icons"
            "jnoortheen.nix-ide"
          ];

          commonSettings = {
            # General Settings
            files.autoSave = "onFocusChange";
            window.zoomLevel = 1.5;
            workbench = {
              iconTheme = "catppuccin-mocha";
              colorTheme = "Default Dark Modern"; # TODO: currently catppuccin is weird, change back when active line is NOT a bright red color (old value: "Catppuccin Mocha", "Default Dark Modern")
            };
            editor = {
              wordWrap = "wordWrapColumn";
              wordWrapColumn = 120;
              semanticHighlighting.enabled = true;
            };

            # Git
            git = {
              autofetch = true;
              enableSmartCommit = true;
              confirmSync = false;
              replaceTagsWhenPull = true;
              openRepositoryInParentFolders = "always";
            };

            # Vim
            vim = {
              useSystemClipboard = true;
              useCtrlKeys = false;
            };

            # Formatting
            "[json]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[jsonc]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[dockercompose]" = {
              "editor.defaultFormatter" = "ms-azuretools.vscode-containers";
            };
            "[scss]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };
            "[typescript]" = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };

            # License Extension
            license = {
              default = "mit";
              author = "Dominik Schwaiger";
            };

            cSpell.language = "en,de-DE";

            # Nix
            nix = {
              enableLanguageServer = true;
              serverPath = "nil"; # or "nixd"
              serverSettings = {
                # check https://github.com/oxalica/nil/blob/main/docs/configuration.md for all options available
                nil = {
                  formatting = {
                    command = ["alejandra"];
                  };
                };
              };
            };
          };
        in {
          default = {
            # don't check
            enableExtensionUpdateCheck = false;
            enableUpdateCheck = false;

            extensions = commonExtensions;

            userSettings = commonSettings;
          };

          vue = {
            extensions =
              commonExtensions
              ++ (getExtensions [
                "nuxtr.nuxtr-vscode"
                "vue.volar"
              ]);

            userSettings =
              commonSettings
              // {
                "[vue]" = {
                  "editor.defaultFormatter" = "esbenp.prettier-vscode";
                };
              };
          };

          python = {
            extensions =
              commonExtensions
              ++ (getExtensions [
                "ms-python.python"
                "ms-python.vscode-pylance"
                # Jupyter + Additional Extensions
                "ms-toolsai.jupyter"
                "ms-toolsai.jupyter-keymap"
                "ms-toolsai.jupyter-renderers"
                "ms-toolsai.vscode-jupyter-cell-tags"
                "ms-toolsai.vscode-jupyter-slideshow"
                "ms-toolsai.vscode-jupyter-powertoys"
              ]);

            userSettings = commonSettings // {};
          };

          typst = {
            extensions =
              commonExtensions
              ++ (getExtensions [
                "myriad-dreamin.tinymist"
                "tomoki1207.pdf" # pdf viewer
              ]);

            userSettings = commonSettings // {};
          };

          rust = {
            extensions =
              commonExtensions
              ++ (getExtensions [
                "rust-lang.rust-analyzer"
              ]);

            userSettings = commonSettings // {};
          };

          empty = {
            extensions = [];
            userSettings = {};
          };
        };
      };
    });
  };
}
