{
  description = "Modularized Nix Configurations for all of my Hosts";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # VS Code Extensions
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    # Agenix, for secret management
    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";

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
      system: (pkgsFor.${system}.alejandra)
    );
  };
}
