{ config, lib, pkgs, ... }:
let
  cfg = config.my.profiles.home-assistant;
  # hostName = config.networking.hostName;

  dreame-vacuum = pkgs.buildHomeAssistantComponent {
    owner = "Tasshack";
    domain = "dreame-vacuum";
    version = "v2.0.0b25";

    src = pkgs.fetchFromGitHub {
      owner = "Tasshack";
      repo = "dreame-vacuum";
      rev = "v2.0.0b25";
      hash = "sha256-eZcv3Xwywt4UDxEU1aP60+KtOj1xibPPahFim2U5gaA=";
    };

    dependencies = with pkgs.python3Packages; [
      "pillow"
      "numpy"
      "requests"
      "pycryptodome"
      "python-miio"
      "mini-racer"
      "paho-mqtt"
    ];
  };
in
{
  options.my.profiles.home-assistant = with lib; {
    enable = mkEnableOption "Home Assistant";
    
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
      
      extraComponents = [
        "shelly"
        "vodafone_station"
      ];

      customComponents = [
        dreame-vacuum
      ];
      
      config = {
	      default_config = {};
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = [ "127.0.0.1" "::1" ];
        };
      };
    };

    # add dns entry to dnsmasq
    my.profiles.dnsConfig.entries = lib.mkIf (cfg.dnsEntry != null) [
      { name = cfg.dnsEntry; port = 8123; }
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
