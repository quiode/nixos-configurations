{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.hm) gvariant;
  inherit (lib.types) listOf str;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.desktop.gnome;
in {
  options.modules.desktop.gnome.enable = mkEnableOption "Gnome Desktop Environment";
  options.modules.desktop.gnome.users = mkOption {
    example = "[quio, domina, ...]";
    description = "The user for which a home manager configuration should be created.";
    type = listOf str;
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services = {
      xserver = {
        enable = true;

        # Enable the GNOME Desktop Environment.
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
    };

    environment = with pkgs; {
      systemPackages =
        (with gnomeExtensions; [
          tray-icons-reloaded
          removable-drive-menu
          gsconnect
          gravatar
          wallpaper-slideshow
          clipboard-history
        ])
        ++ [gnome-tweaks];

      gnome.excludePackages = [
        gnome-photos
        gnome-tour
        gedit # text editor
        cheese # webcam tool
        gnome-music
        epiphany # web browser
        geary # email reader
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        yelp # Help view
        gnome-contacts
        gnome-initial-setup
        gnome-maps
      ];
    };

    home-manager = genAttrs cfg.users (username: {
      # find values using "dconf watch /"
      dconf.settings = with gvariant; {
        # are at "/run/current-system/sw/share/applications"
        "org/gnome/shell".favorite-apps =
          [
            "firefox.desktop"
            "thunderbird.desktop"
            "spotify.desktop"
            "org.gnome.Console.desktop"
            "org.gnome.Nautilus.desktop"
            "signal-desktop.desktop"
          ]
          ++ (mkIf config.modules.programs.vscodium.enable ["codium.desktop"]);
        "org/gnome/mutter".edge-tiling = true; # snap on drag
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          enable-hot-corners = true;
        };
        "org/gnome/desktop/wm/preferences".workspace-names = ["Main"];
        "org/gnome/desktop/session".idle-delay = mkUint32 0;
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
        "org/gnome/shell/extensions/gravatar".email = config.home-manager.${username}.programs.git.userEmail;
        "org/gnome/shell/extensions/azwallpaper".slideshow-directory = "/home/${username}/Pictures/Background";
        "org/gnome/desktop/privacy" = {
          remove-old-temp-files = true;
          remove-old-trash-files = true;
          old-files-age = mkUint32 7;
        };
        # Virtual Machine Default Connection
        "org/virt-manager/virt-manager/connections" = mkIf config.modules.services.vm.enable {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
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

        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
      };
    });
  };
}
