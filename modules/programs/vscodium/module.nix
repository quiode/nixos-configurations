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
  inherit (pkgs) vscodium nil vscode-marketplace;
  cfg = config.modules.programs.vscodium;
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
        extensions = with vscode-marketplace; [
          jnoortheen.nix-ide
          vscodevim.vim
          pkief.material-icon-theme
          ms-azuretools.vscode-docker
          esbenp.prettier-vscode
          ms-python.python
          ms-python.vscode-pylance
          nuxtr.nuxtr-vscode
          vue.volar
          ultram4rine.vscode-choosealicense
        ];
        userSettings = {
          # General Settings
          "files.autoSave" = "onFocusChange";
          "window.zoomLevel" = 1.5;
          "workbench.iconTheme" = "material-icon-theme";
          editor = {
            wordWrap = "wordWrapColumn";
            wordWrapColumn = 120;
          };

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

          # Git
          git = {
            autofetch = true;
            enableSmartCommit = true;
            confirmSync = false;
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
            "editor.defaultFormatter" = "ms-azuretools.vscode-docker";
          };
          "[vue]" = {
            "editor.defaultFormatter" = "Vue.volar";
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
        };
      };
    });
  };
}
