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
      shared = import ./shared { pkgs = nixpkgs; };
    in
    {
      # NixOS configuration entrypoint
      nixosConfigurations.gaming-pc = nixpkgs.lib.nixosSystem
        {
          # set system
          system = "x86_64-linux";
          specialArgs = { inherit inputs outputs; };
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
        }


        };
    }
