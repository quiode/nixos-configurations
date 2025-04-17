nixpkgs.lib.nixosSystem {
  # set system
  system = "x86_64-linux";
  specialArgs = { inherit inputs outputs; };
  # > Our main nixos configuration file <
  modules = [
    ./configuration.nix

    # make home-manager as a module of nixos
    # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
    home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;

      home-manager.users.quio = import ./home-manager/quio.nix;
    }
  ];
}
