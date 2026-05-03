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

      # Services (tiles)
      services = [
        {
          "System" = [
            {
              "Resources" = {
                description = "System metrics";
              };
            }
          ];
        }
      ];

      # Widgets
      widgets = [
        {
          resources = {
            cpu = true;
            units = "metric";
            memory = true;
            disk = "/";
            network = true;
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
