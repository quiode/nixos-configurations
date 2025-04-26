# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{...}: {
  # find values using "dconf watch /"
  dconf.settings = {
    "org/gnome/shell" = {
      # are at "/run/current-system/sw/share/applications"
      favorite-apps = [
        "steam.desktop"
        "vesktop.desktop"
      ];
    };
  };
}
