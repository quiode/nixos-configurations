{
  description = "rustup flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Systems, gets a list of systems, allows easy overriding
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs: let
    eachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
  in {
    devShells = eachSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
    in {
      default = with pkgs;
        mkShell {
          packages = [git rustup];

          shellHook = ''
            export PROJECT_ROOT=$(git rev-parse --show-toplevel)
            export PROJECT_NIX_DIR=$PROJECT_ROOT/.nix
            export CARGO_HOME=$PROJECT_NIX_DIR/cargo
            export RUSTUP_HOME=$PROJECT_NIX_DIR/rustup

            export PATH=$PATH:$CARGO_HOME/bin
          '';
        };
    });
  };
}
