{
  description = "Various Configurations for my Devices";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # VS Code Extensions
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs =
    { self
    , nixpkgs
    , home-manager
    , nix-vscode-extensions
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      # NixOS configuration entrypoint
      nixosConfigurations.gaming-pc = nixpkgs.lib.nixosSystem
        {
          # set system
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs nix-vscode-extensions; };
          # > Our main nixos configuration file <
          modules = [
            ./gaming-pc/configuration.nix
            ./shared/configuration.nix

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.quio =
                { inputs
                , lib
                , config
                , pkgs
                , ...
                }: {
                  imports = [
                    ./gaming-pc/home-manager/quio.nix
                    ./shared/home-manager/quio.nix
                  ];
                };
            }
          ];
        };
    };
}
