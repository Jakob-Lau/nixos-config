# dns server
{ config, lib, ... }:
let 
  cfg = config.my.profiles.dnsConfig;
in 
{
  options.my.profiles.dnsConfig = with lib; {
    enable = mkEnableOption "Local Network DNS Server + Reverse Proxy";

    ipAddress = mkOption {
      type = types.strMatching "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$";
      default = null;
      example = "192.168.0.50";
      description = "The IP Address to route resolve hostnames to.";
    };

    entries = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            example = "paperless";
            description = "Hostname (e.g. paperless)";
          };

          port = mkOption {
            type = types.port;
            example = 8080;
            description = "Target port for the service";
          };
        };
      });
      default = [];
      example = [
        { name = "paperless"; port = 8080; }
      ];
      description = "List of DNS entries mapping hostnames to ports";
    };
  };

  config = lib.mkMerge [
    # --- assertions ---
    {
      assertions = [
        {
          assertion = !cfg.enable || cfg.ipAddress == null;
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
          # Listen on interfaces (local and tailsacle) for DNS requests
          bind-interfaces = false;

          address = builtins.map (entry: "/${entry.name}.home/${cfg.ipAddress}") cfg.entries;

          # Increase cache size to solve "We detected weir network activity from you address" warning
          cache-size = 2000;
        };
      };
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;

        virtualHosts = builtins.listToAttrs (
          builtins.map (entry: {
            name = "${entry.name}.home";
            value = {
              locations."/" = {
                proxyPass = "http://127.0.0.1:${builtins.toString entry.port}";
                proxyWebsockets = true;
              };
            };
          }) cfg.entries
        );
      };

      # set webserver network ports to open (53 required for DNS server)
      networking.firewall.allowedTCPPorts = [ 53 80 443 ];
      networking.firewall.allowedUDPPorts = [ 53 ];
    })
  ];
}
