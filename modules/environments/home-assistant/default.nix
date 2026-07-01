{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.home-assistant;
  # hostName = config.networking.hostName;
in
{
  options.my.profiles.home-assistant = with lib; {
    enable = mkEnableOption "Home Assistant";

    port = mkOption {
      type = types.port;
      default = 8123;
      example = 8123;
      description = "The port on which to listen";
    };
    
    dnsEntry = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "automation";
      description = "Name to add to DNS entries. If null, no entry is added.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.home-assistant = {
      enable = true;
      openFirewall = true;
    };
    services.home-assistant.config.port = cfg.port;

    # add dns entry to dnsmasq
    my.profiles.dnsConfig.entries = lib.mkIf (cfg.dnsEntry != null) [
      { name = cfg.dnsEntry; port = cfg.port; }
    ];


    /* Homepage is currently not relevant
    my.homepage.services = [
      {
        group = "Home";
        name = "Home Assistant";
        description = "Home automation";
        href = "http://${hostName}:8123";
        icon = "si-homeassistant";
      }
    ];
    */
  };
}
