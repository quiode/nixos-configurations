{
  description = "Modularized Nix Configurations for all of my Hosts";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Unstable Nixpkgs
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # VS Code Extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agenix, for secret management
    agenix = {
      url = "github:ryantm/agenix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
        home-manager.follows = "home-manager";
      };
    };

    # nvf, for better vim configuration
    nvf = {
      url = "github:notashelf/nvf";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    # Systems, gets a list of systems, allows easy overriding
    systems.url = "github:nix-systems/x86_64-linux";
  };

  outputs = inputs: let
    eachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
    pkgsFor = inputs.nixpkgs.legacyPackages;
  in {
    # setup dev shell for each system
    devShells = eachSystem (
      system: {
        default = pkgsFor.${system}.callPackage ./shell.nix {};
      }
    );

    # set up formatter for each system
    formatter = eachSystem (
      system: pkgsFor.${system}.alejandra
    );

    # load custom packages
    packages = eachSystem (
      system: import ./packages pkgsFor.${system}
    );

    # do some basic checks
    checks = eachSystem (system: let
      pkgs = pkgsFor.${system};
    in {
      formatting =
        pkgs.runCommand "formatting" {
          src = ./.;
          nativeBuildInputs = with pkgs; [alejandra];
        } ''
          alejandra -c .
          touch "$out"
        '';
    });

    # loads hosts
    nixosConfigurations = import ./hosts inputs;
  };
}
