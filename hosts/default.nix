inputs: let
  inherit (inputs) self;
  inherit (builtins) filter map toString;
  inherit (inputs.nixpkgs) lib;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.lists) concatLists flatten singleton;
  inherit (lib.strings) hasSuffix;
  inherit (lib) nixosSystem;
  # NOTE: Stolen from https://copeberg.org/bloxx12/nichts/src/branch/main/hosts/default.nix

  mkSystem = {
    system,
    hostname,
    ...
  } @ args:
    nixosSystem {
      specialArgs =
        recursiveUpdate
        {
          inherit lib;
          inherit inputs;
          inherit self;
        }
        (args.specialArgs or {});
      modules = concatLists [
        # Home Manager
        singleton
        inputs.home-manager.nixosModules.default
        # Agenix
        singleton
        inputs.agenix.nixosModules.default
        # This is used to pre-emptively set the hostPlatform for nixpkgs.
        # Also, we set the system hostname here.
        (singleton {
          networking.hostName = hostname;
          nixpkgs.hostPlatform = system;
        })
        (flatten (
          concatLists [
            # configuration for the host, passed as an argument.
            (singleton ./${hostname}/default.nix)
            # common configuration,  which all hosts share.
            (singleton ./common.nix)
            # Import all files called module.nix from my modules directory.
            (
              filter (hasSuffix "module.nix") (
                map toString (listFilesRecursive ../modules)
              )
            )
          ]
        ))
      ];
    };
in {
  # Server
  beaststation = mkSystem {
    system = "x86_64-linux";
    hostname = "beaststation";
  };
  # Gaming PC
  artemis = mkSystem {
    system = "x86_64-linux";
    hostname = "artemis";
  };
  # ASUS ROG Gaming Laptop
  hades = mkSystem {
    system = "x86_64-linux";
    hostname = "hades";
  };
}
