{
  description = "Python + extra packages for ML";

  inputs = {
    # unstable nixpgks
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
        mkShellNoCC {
          packages = [
            # python
            (python3.withPackages
              (python-pkgs:
                with python-pkgs; [
                  jupyter
                  pandas
                  tabulate
                  numpy
                  matplotlib
                  scikit-learn
                ]))
          ];
        };
    });
  };
}
