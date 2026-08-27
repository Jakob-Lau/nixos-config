{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.immich;
in
{
  options.my.profiles.immich = with lib; {
    enable = mkEnableOption "Immich Server";

    port = mkOption {
      type = types.port;
      default = 2283;
      example = 2283;
      description = "Internal port for webui";
    };

    dnsEntry = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "paperless";
      description = "Name to add to DNS entries. If null, no entry is added.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = "127.0.0.1";
      port = cfg.port;
    };
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    # add dns entry to dnsmasq
    my.profiles.dnsConfig.entries = lib.mkIf (cfg.dnsEntry != null) [
      {
        name = cfg.dnsEntry;
        port = cfg.port;
        extraConfig = ''
          client_max_body_size "0"
          proxy_read_timeout "600s"
          proxy_send_timeout "600s"
        '';
      }
    ];
  };
}
