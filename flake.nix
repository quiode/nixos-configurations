{
  description = "Various Configurations for my Devices";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      gaming-pc = (import ./gaming-pc);
    in
    {
      # NixOS configuration entrypoint
      nixosConfigurations.gaming-pc = nixpkgs.lib.nixosSystem gaming-pc;
    };
}
