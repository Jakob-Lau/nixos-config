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
    };

    dnsEntry = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "paperless";
      description = "Name to add to DNS entries. If null, no entry is added.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.paperless = {
      enable = true;
      address = "0.0.0.0";
      port = cfg.port;
      settings = cfg.settings;
    };
    networking.firewall.allowedTCPPorts = [ cfg.port ];
    # add dns entry to dnsmasq
    my.profiles.dnsConfig.entries = lib.mkIf (cfg.dnsEntry != null) [
      { name = cfg.dnsEntry; port = cfg.port; }
    ];
    # backup description
    my.profiles.backup.jobs.paperless = {
      script = ''
        echo "Stopping Paperless..."
        ${pkgs.systemd}/bin/systemctl stop paperless.service

        restart_paperless() {
          echo "Starting Paperless..."
          ${pkgs.systemd}/bin/systemctl start paperless.service
        }

        trap restart_paperless EXIT

        echo "Backing up Paperless media..."

        ${pkgs.rsync}/bin/rsync -a \
          /var/lib/paperless/ \
          "$BACKUP_DIR/"
      '';
    };
  };
}
