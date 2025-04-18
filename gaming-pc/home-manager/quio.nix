# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ ... }:
{
  # You can import other home-manager modules here
  imports = [ ];

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
