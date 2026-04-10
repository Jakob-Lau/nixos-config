{ config, lib, ... }:
let 
  cfg = config.my.profiles.paperless;
in
{
  options.my.profiles.paperless = with lib; {
    enable = mkEnableOption "Paperless Server";

    port = mkOption {
      type = types.port;
      default = 28981;
      example = 8080;
      description = "Internal port for webui";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = {
        PAPERLESS_OCR_LANGUAGE = "deu+eng";
      };
      description = "Extra configuration options";
    }
  };

  config = lib.mkIf cfg.enable {
    services.paperless = {
      enable = true;
      # address = "0.0.0.0";
      port = cfg.port;
      settings = cfg.settings;
    }
  }
}