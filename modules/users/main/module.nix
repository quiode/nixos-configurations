{lib, ...}: let
  inherit (lib.types) str;
  inherit (lib.options) mkOption;
in {
  options.modules.users.main = mkOption {
    description = "The main user of the System.";
    type = str;
    example = "quio";
  };
}
