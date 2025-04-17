{ config, pkgs, ... }: {
  configuration = import ./configuration.nix { inherit config pkgs; };
  home-manager = import ./home-manager;
}
