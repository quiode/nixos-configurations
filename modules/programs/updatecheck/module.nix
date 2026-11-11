{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.programs.updatecheck;

  updateCheck = pkgs.writeShellApplication {
    name = "update-check";
    runtimeInputs = [pkgs.fwupd pkgs.jq];
    text = ''
      # Reboot needed: the booted kernel differs from the one in the current system closure.
      if [ -e /run/booted-system/kernel ] && [ -e /run/current-system/kernel ]; then
        booted=$(readlink -f /run/booted-system/kernel)
        current=$(readlink -f /run/current-system/kernel)
        if [ "$booted" != "$current" ]; then
          echo "reboot needed: booted kernel differs from the current system generation"
        fi
      fi

      if command -v fwupdmgr >/dev/null 2>&1; then
        # Firmware updates: fwupdmgr exits 0 when updates are available, 2 when there is nothing to do.
        if fwupdmgr get-updates >/dev/null 2>&1; then
          echo "firmware updates available: run 'fwupdmgr update'"
        fi

        # Reboot needed to finish applying a firmware update (fwupd UpdateState 4 == NEEDS_REBOOT).
        # Avoids 'fwupdmgr check-reboot-needed', which prompts interactively to shut down.
        pendingReboot=$(fwupdmgr get-devices --json 2>/dev/null | jq -r '[.Devices[]? | select(.UpdateState == 4) | .Name] | join(", ")')
        if [ -n "$pendingReboot" ]; then
          echo "reboot needed to finish firmware update: $pendingReboot"
        fi
      fi
    '';
  };
in {
  options.modules.programs.updatecheck.enable = mkEnableOption "alert on shell startup about pending firmware updates or a required reboot";

  config = mkIf cfg.enable {
    environment.systemPackages = [updateCheck];

    environment.interactiveShellInit = ''
      ${updateCheck}/bin/update-check
    '';
  };
}
