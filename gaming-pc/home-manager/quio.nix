# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ shared, ... }: {
  # You can import other home-manager modules here
  imports = [
    shared.home-manager.quio
  ];
}
