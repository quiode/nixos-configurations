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
    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
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
      url = "github:notashelf/nvf/0e8c165a8ae5edd46336730f5a7f51a5f7f368e2"; # TODO: when fixed, pin to current version

      inputs = {
        nixpkgs.follows = "nixpkgs";
        systems.follows = "systems";
      };
    };

    # Systems, gets a list of systems, allows easy overriding
    systems.url = "github:nix-systems/x86_64-linux";

    # rust-overlay: for easier rust management
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
