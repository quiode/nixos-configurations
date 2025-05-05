{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.desktop.gnome;
in {
  options.modules.desktop.gnome.enable = mkEnableOption "Gnome Desktop Environment";

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
  };
}
