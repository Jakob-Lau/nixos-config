# dns server
{ config, lib, ... }:
let 
  cfg = config.my.profiles.dnsConfig;
in 
{
  options.my.profiles.dnsConfig = with lib; {
    enable = mkEnableOption "Local Network DNS Server + Reverse Proxy";

    ipAddress = mkOption {
      type = types.strMatching "^[\d]+\.[\d]+\.[\d]+\.[\d]+$";
      default = null;
      example = "192.168.0.50";
      description = "The IP Address to route resolve hostnames to.";
    };

    entries = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [
        "paperless"
      ];
      description = ""
    };
  };

  config = lib.mkMerge [
    # --- assertions ---
    {
      assertions = [
        {
          assertion = !cfg.enable || cfg.ipAddress != null;
          message = "dnsConfig: ipAddress must be set when enable = true";
        }

        {
          assertion = !cfg.enable || cfg.entries != [];
          message = "dnsConfig: entries must contain at least one hostname when enabled = true";
        }
      ];
    }

    # --- actual config ---
    (lib.mkIf cfg.enable {
      services.dnsmasq = {
        enable = true;
        settings = {
          server = [
            "8.8.8.8"
            "8.8.4.4"
          ];
          address = builtins.map (host: "/${host}.home/${cfg.ipAddress}") cfg.entries;
        };
      };
    })
  ];
}