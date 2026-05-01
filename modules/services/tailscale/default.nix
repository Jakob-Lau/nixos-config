{ config, lib, ... }:
let 
  cfg = config.my.profiles.tailscale;
in
{
  options.my.profiles.tailscale = with lib; {
    enable = mkEnableOption "Tailscale VPN Setup";

    subnetRouter = mkOption {
      type = types.nullOr types.strMatching "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$";
      default = null;
      example = 192.168.0.0/24;
      description = ''
      Provide this option setup this tailscale client as subnet router.
      The address provided will be set in the 'advertise-routes' parameter.
      Take the IP Address of the server of the local network
      and replace the last part with '0' and add '/24' in standard network.
      '';
    };

    authKeyFilePath = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/tailscale-key";
      description = ''
      Path to a file containing a Tailscale auth key.
      If set, this device will automatically authenticate to Tailscale.
      If unset, manual login via `tailscale up` is required.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      
      authKeyFile = lib.mkIf (cfg.authKeyFilePath != null) cfg.authKeyFilePath;

      extraUpFlags = lib.optionals (cfg.subnetRouter != null) [
        "--advertise-routes=${cfg.subnetRouter}"
      ];
      
    };
  };
}