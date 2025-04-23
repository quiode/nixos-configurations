# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  pkgs,
  lib,
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
    bash = {
      enable = true;
      bashrcExtra = "fastfetch";
    };

    home-manager.enable = true;

    git = {
      enable = true;
      userName = "Dominik Schwaiger";
      userEmail = "mail@dominik-schwaiger.ch";
      signing = {
        signByDefault = true;
        key = "D9FE 655C CD52 8F80 3D27 8F75 F7E7 E19B C69F 7DF5";
      };
      extraConfig = {
        pull.rebase = true;
      };
    };

    vscode = {
      enable = true;
      package = pkgs.vscodium;
      mutableExtensionsDir = false;
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        vscodevim.vim
        pkief.material-icon-theme
        ms-azuretools.vscode-docker
        esbenp.prettier-vscode
        ms-python.python
        ms-python.vscode-pylance
      ];
      userSettings = {
        # General Settings
        "files.autoSave" = "onFocusChange";
        "window.zoomLevel" = 1.5;
        "workbench.iconTheme" = "material-icon-theme";

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
        "git.confirmSync" = false;

        # Vim
        "vim.useSystemClipboard" = true;
        "vim.useCtrlKeys" = false;

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
      };
    };

    ssh = {
      enable = true;
      matchBlocks = {
        home = {
          hostname = "dominik-schwaiger.ch";
          port = 2222;
          user = "domina";
        };

        home-root = {
          hostname = "dominik-schwaiger.ch";
          port = 2222;
          user = "root";
        };

        backup = {
          hostname = "yniederer.ch";
          port = 2222;
          user = "domina";
        };

        eth = {
          hostname = "dominik-schwaiger.vsos.ethz.ch";
          user = "ubuntu";
        };
      };
    };
  };

  # find values using "dconf watch /"
  dconf.settings = with lib.hm.gvariant; {
    "org/gnome/shell" = {
      # are at "/run/current-system/sw/share/applications"
      favorite-apps = [
        "firefox.desktop"
        "thunderbird.desktop"
        "codium.desktop"
        "spotify.desktop"
        "org.gnome.Console.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      workspace-names = [ "Main" ];
    };
    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 0;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
    "org/gnome/shell/extensions/gravatar" = {
      email = "mail@dominik-schwaiger.ch";
    };
    "org/gnome/shell/extensions/azwallpaper" = {
      slideshow-directory = "/home/quio/Pictures/Background";
    };
    # Virtual Machine Default Connection
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
    "org/gnome/shell" = {
      disable-user-extensions = false;

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "trayIconsReloaded@selfmade.pl"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "gravatar@dsheeler.net"
        "gsconnect@andyholmes.github.io"
        "azwallpaper@azwallpaper.gitlab.com"
        "clipboard-history@alexsaveau.dev"
      ];
    };

    # Custom Keybinds
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      binding = "<Super>Return";
      command = "kgx";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Firefox";
      binding = "<Super>W";
      command = "firefox";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "Files";
      binding = "<Super>F";
      command = "nautilus";
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
    };
  };

  services = {
    nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
