 # enabled profiles
 { config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  my.profiles = {
    backup = {
      enable = true;
      device = "/dev/disk/by-uuid/40332bb2-1e4f-4887-add0-867f19048dc8";
      mountPoint = "/mnt/backup";
      schedule = "Sun 03:00";
    };

    dnsConfig = {
      enable = true;
      ipAddress = "192.168.0.96";
    };

    homepage.enable = true;

    #home-assistant = {
    #  enable = true;
    #  dnsEntry = "automation";
    #};

    tailscale = {
      enable = true;
      subnetRouter = "192.168.0.0/24";
      # authKeyFilePath = "/run/secrets/tailscale-key";
    };

    paperless = {
      enable = true;
      dnsEntry = "paperless";
      port = 28981;
      settings =  {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_ADMIN_USER= "jakob";
      };
    };
  };
}
