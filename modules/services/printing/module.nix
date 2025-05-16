{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;
  cfg = config.modules.services.printing;
in {
  options.modules.services.printing.enable = mkEnableOption "Enable Printing";

  config = mkIf cfg.enable {
    services = {
      # local printing
      printing = {
        enable = true;
        browsing = true;

        browsedConf = ''
          BrowseDNSSDSubTypes _cups,_print
          BrowseLocalProtocols all
          BrowseRemoteProtocols all
          CreateIPPPrinterQueues All

          BrowseProtocols all
        '';

        drivers = with pkgs; [gutenprint gutenprintBin canon-cups-ufr2 cups-bjnp cups-filters cnijfilter2];
      };

      # IPP Everywhere protocol
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
  };
}
