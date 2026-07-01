{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.profiles.homepage;
  dashboardPort = 8082;
  dashboardHost = "dashboard";
in
{
  options.my.profiles.homepage = with lib; {
    enable = mkEnableOption "Homepage Dashboard";
  };

  config = lib.mkIf cfg.enable {
    services.homepage-dashboard = {
      enable = true;
      listenPort = dashboardPort;
      allowedHosts = "${dashboardHost}.home,localhost:${toString dashboardPort},127.0.0.1:${toString dashboardPort}";

      settings = {
        # title = dashboardHost;
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
      { name = dashboardHost; port = dashboardPort; }
    ];
  };
}
