{
  mkShellNoCC,
  git,
  writeShellApplication,
  nh,
}: let
  current_dir = builtins.toString ./.;
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
          nix flake update --commit-lock-file --flake ${current_dir}
        '';
      })

      (writeShellApplication {
        name = "upgrade";
        text = ''
          nh os switch ${current_dir}
        '';
      })
    ];
  }
