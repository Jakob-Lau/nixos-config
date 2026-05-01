 # enabled profiles
 { config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  my.profiles = {
    dnsConfig = {
      enable = true;
      ipAddress = "192.168.0.96";
      tailscaleIpAddress = "100.73.143.17";
    };

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
