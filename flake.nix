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
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    # install agenix, for secret management
    agenix.url = "github:ryantm/agenix";
    # optional, not necessary for the module
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
  in {
    formatter.x86_64-linux = pkgs.alejandra;

    devShells.x86_64-linux.default = pkgs.callPackage ./shell.nix {};

    # Gaming PC Configuration Entrypoint
    nixosConfigurations.gaming-pc = inputs.nixpkgs.lib.nixosSystem {
      # set system
      inherit system;
      specialArgs = {
        inherit inputs;
        inherit (inputs) self;
      };
      # > Our main nixos configuration file <
      modules = [
        ./gaming-pc/configuration.nix
        ./shared/configuration.nix

        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users.quio = _: {
              imports = [
                ./gaming-pc/home-manager/quio.nix
                ./shared/home-manager/quio.nix
              ];
            };
          };
        }

        # insert agenix
        inputs.agenix.nixosModules.default
      ];
    };

    # Laptop Configuration Entrypoint
    nixosConfigurations.laptop = inputs.nixpkgs.lib.nixosSystem {
      # set system
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        inherit (inputs) self;
      };
      # > Our main nixos configuration file <
      modules = [
        ./laptop/configuration.nix
        ./shared/configuration.nix

        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
        inputs.home-manager.nixosModules.default
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            users.quio = _: {
              imports = [
                ./laptop/home-manager/quio.nix
                ./shared/home-manager/quio.nix
              ];
            };
          };
        }

        # insert agenix
        inputs.agenix.nixosModules.default
      ];
    };
  };
}
