{
  mkShellNoCC,
  git,
  writeShellApplication,
  nh,
}: let
  flake_dir = builtins.toString ./.;
in
  mkShellNoCC {
    name = "Nix Configurations";

    DIRENV_LOG_FORMAT = "";

    packages = [
      git # take a guess
      nh # for upgrading

      (writeShellApplication {
        name = "update";
        text = ''
          nix flake update --commit-lock-file --flake ${flake_dir}
        '';
      })

      (writeShellApplication {
        name = "upgrade";
        text = ''
          nh os switch ${flake_dir}
        '';
      })
    ];
  }
