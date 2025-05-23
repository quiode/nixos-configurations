{
  mkShellNoCC,
  git,
  writeShellApplication,
  nh,
  alejandra,
}:
mkShellNoCC {
  name = "Nix Configurations";

  DIRENV_LOG_FORMAT = "";

  packages = [
    git # take a guess
    nh # for upgrading
    alejandra # for formatting

    (writeShellApplication {
      name = "update";
      text = ''
        nix flake update --flake .
      '';
    })

    (writeShellApplication {
      name = "upgrade";
      text = ''
        nh os switch
      '';
    })

    (writeShellApplication {
      name = "push";
      text = ''
        nix flake check && git push
      '';
    })

    (writeShellApplication {
      name = "format";
      text = ''
        alejandra .
      '';
    })
  ];
}
