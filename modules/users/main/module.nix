{lib, ...}: let
  inherit (lib.types) str listOf;
  inherit (lib.options) mkOption;
in {
  options.modules.users.main = mkOption {
    description = "The main users of the System. All custom settings (dotfiles) will be applied to them.";
    type = listOf str;
    example = ["quio"];
  };
}
