# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  pkgs,
  ...
}:
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use home-manager modules from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModule

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "quio";
    homeDirectory = "/home/quio";
  };

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "Dominik Schwaiger";
      userEmail = "mail@dominik-schwaiger.ch";
    };
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        vscodevim.vim
        pkief.material-icon-theme
      ];
      userSettings = {
        # General Settings
        "files.autoSave" = "onFocusChange";
        "window.zoomLevel" = 1;

        # Nix
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil"; # or "nixd"
        "nix.serverSettings" = {
          # check https://github.com/oxalica/nil/blob/main/docs/configuration.md for all options available
          "nil" = {
            "formatting" = {
              "command" = [ "nixfmt" ];
            };
          };
        };

        # Git
        "git.enableSmartCommit" = true;

        # Vim
        "vim.useSystemClipboard" = true;
        "vim.useCtrlKeys" = false;
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
