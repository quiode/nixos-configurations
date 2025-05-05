pkgs: let
  inherit (pkgs) lib callPackage;
  inherit (lib) filter;
  inherit (lib.filesystem) listFilesRecursive;
in let
  # Recursively list all files from the current directory
  allFiles = listFilesRecursive ./.;
  # Filter for .nix files that are not default.nix and directories with package.nix
  packagePaths =
    filter
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
        baseName = builtins.baseNameOf path;
        name =
          if baseName == "package.nix"
          then builtins.baseNameOf (builtins.dirOf path)
          else builtins.substring 0 (builtins.stringLength baseName - (builtins.stringLength ".nix")) baseName;
      in {
        name = name;
        value = callPackage path {};
      }
    )
    packagePaths);
in
  packages
