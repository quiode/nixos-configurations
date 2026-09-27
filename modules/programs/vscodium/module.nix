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
  inherit (pkgs) vscodium nil nix4vscode vscode-extensions;
  cfg = config.modules.programs.vscodium;
  getExtensions = nix4vscode.forVscodeVersion vscodium.version;
in {
  options.modules.programs.vscodium.enable = mkEnableOption "VSCodium";
  options.modules.programs.vscodium.difftool = mkOption {
    type = types.bool;
    default = true;
    description = "Use VSCodium as diff tool in git";
  };
  options.modules.programs.vscodium.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf types.str;
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [nil];

    # use vscodium as diff tool in git
    programs.git.config = mkIf cfg.difftool {
      diff.tool = "vscodium";
      difftool.vscodium.cmd = "codium --wait --diff $LOCAL $REMOTE";
    };

    home-manager.users = genAttrs cfg.users (username: {
      programs.vscodium = {
        enable = true;
        mutableExtensionsDir = false;

        profiles = let
          commonExtensions =
            (getExtensions [
              "ultram4rine.vscode-choosealicense"
              "edwinhuish.better-comments-next"
              "github.copilot-chat"
            ])
            ++ (with vscode-extensions; [
              vscodevim.vim
              ms-azuretools.vscode-containers
              esbenp.prettier-vscode
              tomoki1207.pdf # pdf viewer
              streetsidesoftware.code-spell-checker # spellcheck
              streetsidesoftware.code-spell-checker-german # spellcheck - german addon
              catppuccin.catppuccin-vsc
              catppuccin.catppuccin-vsc-icons
              jnoortheen.nix-ide
              tamasfe.even-better-toml
              anthropic.claude-code
              foxundermoon.shell-format
              mkhl.direnv
            ]);

          commonSettings = {
            # General Settings
            files.autoSave = "onFocusChange";
            window.zoomLevel = 1.5;
            "workbench.iconTheme" = "catppuccin-mocha"; # writing it like this fixes a bug that it tries to insert itself at the end of the document if done normally
            workbench = {
              colorTheme = "Catppuccin Mocha";
            };
            editor = {
              wordWrap = "wordWrapColumn";
              wordWrapColumn = 120;
              semanticHighlighting.enabled = true;
            };
            telemetry.telemetryLevel = "all"; # better support for nix :D
            terminal.integrated.defaultProfile.linux = "zsh";
            update.showReleaseNotes = false; # don't show release notes after update
            security.workspace.trust.untrustedFiles = "open";
            workbench.editor.empty.hint = "hidden";

            # AI
            chat.disableAIFeatures = false;
            claudeCode.preferredLocation = "sidebar";

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
              editor.defaultFormatter = "esbenp.prettier-vscode";
            };
            "[jsonc]" = {
              editor.defaultFormatter = "esbenp.prettier-vscode";
            };
            "[dockercompose]" = {
              editor.defaultFormatter = "ms-azuretools.vscode-containers";
            };
            "[dockerfile]" = {
              editor.defaultFormatter = "ms-azuretools.vscode-containers";
            };
            "[scss]" = {
              editor.defaultFormatter = "esbenp.prettier-vscode";
            };
            "[typescript]" = {
              editor.defaultFormatter = "esbenp.prettier-vscode";
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
              ])
              ++ (with vscode-extensions; [
                vue.volar
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
                "ms-python.autopep8"
                "ms-toolsai.vscode-jupyter-powertoys"
              ])
              ++ (with vscode-extensions; [
                ms-python.python
                ms-python.vscode-pylance
                # Jupyter + Additional Extensions
                ms-toolsai.jupyter
                ms-toolsai.jupyter-keymap
                ms-toolsai.jupyter-renderers
                ms-toolsai.vscode-jupyter-cell-tags
                ms-toolsai.vscode-jupyter-slideshow
              ]);

            userSettings =
              commonSettings
              // {
                jupyter.askForKernelRestart = false;
              };
          };

          typst = {
            extensions =
              commonExtensions
              ++ (with vscode-extensions; [
                myriad-dreamin.tinymist
                tomoki1207.pdf
              ]);

            userSettings = commonSettings // {};
          };

          rust = {
            extensions =
              commonExtensions
              ++ (with vscode-extensions; [
                vadimcn.vscode-lldb
                rust-lang.rust-analyzer
              ]);

            userSettings =
              commonSettings
              // {
                rust-analyzer.check.command = "clippy";
              };
          };

          java = {
            extensions =
              commonExtensions
              ++ (with vscode-extensions; [
                redhat.java
                vscjava.vscode-java-debug
                vscjava.vscode-java-test
                vscjava.vscode-maven
                vscjava.vscode-gradle
                vscjava.vscode-java-dependency
              ]);
            userSettings =
              commonSettings
              // {
                redhat.telemetry.enabled = true;
              };
          };

          ocaml = {
            extensions =
              commonExtensions
              ++ (with vscode-extensions; [
                ocamllabs.ocaml-platform
              ]);
            userSettings =
              commonSettings
              // {
              };
          };

          # TODO: remove then no longer used or can't be fixed
          stm32 = let
            stmExtensions = getExtensions [
              "stmicroelectronics.stm32-vscode-extension"
              "stmicroelectronics.stm32cube-ide-registers"
              "stmicroelectronics.stm32cube-ide-build-cmake"
              "stmicroelectronics.stm32cube-ide-build-analyzer"
              "stmicroelectronics.stm32cube-ide-bundles-manager"
              "stmicroelectronics.stm32cube-ide-debug-jlink-gdbserver"
              "stmicroelectronics.stm32cube-ide-debug-core"
              "stmicroelectronics.stm32cube-ide-debug-stlink-gdbserver"
              "stmicroelectronics.stm32cube-ide-clangd"
              "stmicroelectronics.stm32cube-ide-project-manager"
              "stmicroelectronics.stm32cube-ide-rtos"
              "stmicroelectronics.stm32cube-ide-core"
              "stmicroelectronics.stm32cube-ide-debug-generic-gdbserver"
              "ms-vscode.cmake-tools"
              "ms-vscode.vscode-serial-monitor"
            ];

            # path inside an extension
            extPath = id: sub: let
              ext = lib.findFirst (e: e.vscodeExtUniqueId == id) (throw "missing ${id}") stmExtensions;
            in "${ext}/share/vscode/extensions/${id}/${sub}";

            cubeCmake = extPath "stmicroelectronics.stm32cube-ide-build-cmake" "resources/cube-cmake/linux/x86_64";
            cubeBinaries = extPath "stmicroelectronics.stm32cube-ide-core" "resources/binaries/linux/x86_64";
          in {
            extensions = commonExtensions ++ stmExtensions;

            userSettings =
              commonSettings
              // {
                cmake.environment.PATH = "${cubeCmake}:${cubeBinaries}:\${env:PATH}";
              };
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
