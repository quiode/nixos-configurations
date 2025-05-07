{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs) zsh chroma;
  inherit (lib) genAttrs;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.programs.zsh;
in {
  options.modules.programs.zsh.enable = mkEnableOption "Enable ZSH Shell";
  options.modules.programs.zsh.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    programs.zsh.enable = true;

    users.users = genAttrs cfg.users (username: {
      shell = zsh;
    });

    home-manager.users = genAttrs cfg.users (username: {
      programs = {
        zsh = {
          enable = true;
          enableCompletion = true;

          autosuggestion = {
            enable = true;
          };

          history.append = true;

          shellAliases = {
            upgrade = "nh os switch /config";
          };

          # see https://github.com/ohmyzsh/ohmyzsh/wiki
          oh-my-zsh = {
            enable = true;
            theme = "robbyrussell";
            plugins = ["extract" "colorize" "globalias" "autojump"];
          };
        };

        autojump = {
          enable = true;
          enableZshIntegration = true;
        };

        atuin.enableZshIntegration = true;
      };
    });

    environment = {
      pathsToLink = ["/share/zsh"];

      systemPackages = [
        chroma # needed for colorize plugin
      ];
    };
  };
}
