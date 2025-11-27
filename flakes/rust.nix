{
  description = "Stable Rust";

  inputs = {
    # unstable nixpgks
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # rust overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Systems, gets a list of systems, allows easy overriding
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs: let
    eachSystem = inputs.nixpkgs.lib.genAttrs (import inputs.systems);
  in {
    devShells = eachSystem (system: let
      overlays = [(import inputs.rust-overlay)];
      pkgs = import inputs.nixpkgs {
        inherit system overlays;
      };
    in {
      default = with pkgs;
        pkgs.mkShellNoCC {
          buildInputs = [
            openssl
            pkg-config
            (rust-bin.stable.latest.default.override {
              extensions = ["rust-src"];
            })
          ];
        };
    });
  };
}
