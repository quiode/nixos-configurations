# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
_: {
  # find values using "dconf watch /"
  dconf.settings = {
    # are at "/run/current-system/sw/share/applications"
    "org/gnome/shell".favorite-apps = [
      "steam.desktop"
      "vesktop.desktop"
    ];
  };
}
