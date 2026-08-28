{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.homepage;
  domain = config.my.profiles.dnsConfig.domain;
  dashboardPort = 8082;
in
{
  options.my.profiles.homepage = with lib; {
    enable = mkEnableOption "Homepage Dashboard";

    host = mkOption {
      type = types.str;
      example = "dashboard";
      description = "The hostname of this service.";
    };

    domain = mkOption {
      type = types.str;
      example = "example.com";
      description = "The domain the service is running on. Required to set the allowedHosts";
    };
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = dashboardPort;
      allowedHosts = "${cfg.host}.${cfg.domain},localhost:${toString dashboardPort},127.0.0.1:${toString dashboardPort}";

      settings = {
        headerStyle = "clean";
        language = "en";
        target = "_blank";
        color = "slate";
      };

      # TODO services should define their services itself, not hardcoded in the dashboard
      # Services (tiles)
      services = [
        {
          "Documents" = [
            {
              "Paperless" = {
                icon = "paperless-ngx.png";
                href = "http://paperless.home";
                description = "Document management";
              };
            }
          ];
        }
      ];

      # Widgets
      widgets = [
        # Clock
        {
          datetime = {
            locale = "de";
            format = {
              dateStyle = "long";
              timeStyle = "short";
            };
          };
        }

        # System resources
        {
          resources = {
            cpu = true;
            units = "metric";
            memory = true;
            disk = "/";
            network = true;
            uptime = true;
          };
        }
      ];
    };

    # add dns entry to dnsmasq
    my.profiles.dnsConfig.entries = [
      { name = cfg.host; port = dashboardPort; }
    ];
  };
}
