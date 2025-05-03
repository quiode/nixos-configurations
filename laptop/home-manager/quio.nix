# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
_: {
  # find values using "dconf watch /"
  dconf.settings = {
    # are at "/run/current-system/sw/share/applications"
    "org/gnome/shell".favorite-apps = ["com.github.xournalpp.xournalpp.desktop"];
    "org/gnome/desktop/peripherals/touchpad" = {
      click-method = "areas";
    };
    # Fixes for ASUS Specific Laptop
    "org/gnome/shell/keybindings".show-screenshot-u = ["<Shift><Super>s" "<Print>"];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/btop" = {
      name = "Btop";
      binding = "Launch1";
      command = "kgx -e btop";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch3" = {
      name = "TODO 3";
      binding = "Launch3";
      command = ''kgx -e "echo TODO: Launch3"'';
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch4" = {
      name = "TODO 4";
      binding = "Launch4";
      command = ''kgx -e "echo TODO: Launch4"'';
    };
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/btop/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch3/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch4/"
    ];
  };
}
