{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf;
in {
  boot.initrd.luks.devices."luks-e33fcdd4-9e85-413e-bd46-6f141716d32a".device = "/dev/disk/by-uuid/e33fcdd4-9e85-413e-bd46-6f141716d32a";

  environment.systemPackages = with pkgs; [
    xournalpp
    keyd # to minitor key press event, used with keyd service below
  ];

  services = {
    # for ROG Laptop
    supergfxd.enable = true;
    asusd = {
      enable = true;
      enableUserService = true;
    };

    # Fix Keyboard
    xserver.xkb.model = "asus_laptop";
    keyd = {
      enable = true;
      keyboards = {
        built-in = {
          ids = ["0b05:19b6:42ab166f"];
          settings = {
            "meta+shift" = {
              "s" = "print";
            };
          };
        };
      };
    };
  };

  home-manager.users = genAttrs [config.modules.users.main] (username: {
    # find values using "dconf watch /"
    dconf.settings = mkIf config.modules.desktop.gnome.enable {
      # are at "/run/current-system/sw/share/applications"
      "org/gnome/shell".favorite-apps = ["com.github.xournalpp.xournalpp.desktop"];
      "org/gnome/desktop/peripherals/touchpad".click-method = "areas";
      # Fixes for ASUS Specific Laptop
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/btop" = {
        name = "Btop";
        binding = "Launch1";
        command = "kgx -e btop";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch3" = {
        name = "TODO 3";
        binding = "Launch3";
        command = ''kgx -e "echo TODO: Launch3"'';
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch4" = {
        name = "TODO 4";
        binding = "Launch4";
        command = ''kgx -e "echo TODO: Launch4"'';
      };
      "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/btop/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/launch4/"
      ];
    };
  });
}
