 # enabled profiles
 { config, lib, ... }:
let
  secrets = config.sops.secrets;
in
{
  my.profiles = {
    paperless = {
      enable = true;
      port = 28981;
      settings =  {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
        PAPERLESS_ADMIN_USER= "jakob";
      };
    };
  };
}
