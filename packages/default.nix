{pkgs}: let
  # Recursively list all files from the current directory
  allFiles = pkgs.lib.filesystem.listFilesRecursive (toString ./.);

  # Filter for .nix files that are not default.nix and directories with package.nix
  packagePaths =
    pkgs.lib.filter
    (
      path: let
        baseName = builtins.baseNameOf path;
        isNixFile = builtins.match ".+\\.nix$" baseName != null && baseName != "default.nix";
        isPackageNix = baseName == "package.nix";
      in
        isNixFile || isPackageNix
    )
    allFiles;

  # Create an attribute set using these paths
  packages = builtins.listToAttrs (map
    (
      path: let
        name =
          if builtins.baseNameOf path == "package.nix"
          then builtins.baseNameOf (builtins.dirOf path)
          else builtins.removeSuffix ".nix" (builtins.baseNameOf path);
      in {
        name = name;
        value = pkgs.callPackage path {};
      }
    )
    packagePaths);
in
  packages
