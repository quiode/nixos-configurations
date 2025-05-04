# This file is imported in all systems. Only include essential configs.
{
  self,
  pkgs,
  ...
}: {
  environment.systemPackages = (with pkgs; []) ++ (with self.packages.${pkgs.stdenv.system}; []);

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
