{
  description = "Compiler Design Flake";

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
          packages =
            [
              ocaml # ocaml compiler
              opam # package manager
            ]
            ++ (with pkgs.ocamlPackages; [
              dune # package manager
              ocamlbuild # build system
              merlin # editor support
              ocamlformat # code formatting
              ocaml-lsp # language server
            ]);
        };
    });
  };
}
