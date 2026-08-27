{ config, lib, pkgs, ...}:
let
  cfg = config.my.profiles.backup;

  # type definition of a job
  jobType = lib.types.submodule {
    options = {
      script = lib.mkOption {
        type = lib.types.lines;
        description = "Script to execute for this backup job.";
      };
    };
  };

  # generates a list of jobs out of an attribute
  jobs = lib.mapAttrsToList
    (name: job: {
      inherit name;
      inherit (job) script;
    })
    cfg.jobs;

  # Creates the shell script that contains all the backup scripts from the jobs
  jobScripts = lib.concatMapStringsSep "\n" (job: ''
    echo "Starting backup job: ${job.name}"

    export BACKUP_DIR="${cfg.mountPoint}/${job.name}"

    mkdir -p "$BACKUP_DIR"

    ${job.script}

    echo "Backup job completed: ${job.name}"
  '') jobs;
in
{
  options.my.profiles.backup = with lib; {
    enable = mkEnableOption "Backup Cronjob";

    device = lib.mkOption {
      type = lib.types.str;
      description = "Block device containing the backup filesystem.";
      example = "/dev/disk/by-uuid/1234-5678";
    };

    mountPoint = lib.mkOption {
      type = lib.types.path;
      description = "Where to mount the backup filesystem.";
    };

    schedule = lib.mkOption {
      type = lib.types.str;
      default = "Sun 03:00";
      description = "When the backup should run.";
    };

    jobs = lib.mkOption {
      type = lib.types.attrsOf jobType;
      default = {};
      description = "Backup jobs registered by services.";
    };
  };

  config = {
    assertions = [
      {
        assertion = !cfg.enable || cfg.jobs != {};
        message = "services.backup.enable requires at least one backup job.";
      }
    ];

    systemd.services.server-backup = lib.mkIf cfg.enable {
      description = "Backup the services data on this server";

      serviceConfig = {
        Type = "oneshot";

        ExecStart = pkgs.writeShellScript "server-backup" ''
          set -euo pipefail

          MOUNT_POINT="${cfg.mountPoint}"

          cleanup() {
            local exit_code=$?

            echo "Unmounting backup drive..."

            if ! ${pkgs.util-linux}/bin/umount "$MOUNT_POINT"; then
              echo "ERROR: failed to unmount backup drive"
              exit_code=1
            fi

            exit "$exit_code"
          }

          trap cleanup EXIT

          echo "Mounting backup drive..."

          mkdir -p "$MOUNT_POINT"

          ${pkgs.util-linux}/bin/mount \
            "${cfg.device}" \
            "$MOUNT_POINT"

          # Make absolutely sure that we mounted something.
          if ! ${pkgs.util-linux}/bin/mountpoint -q "$MOUNT_POINT"; then
            echo "ERROR: backup drive is not mounted"
            exit 1
          fi

          echo "Backup drive mounted."

          ${jobScripts}

          echo "All backup jobs completed."
        '';

        TimeoutStartSec = "6h";
      };
    };

    systemd.timers.server-backup = lib.mkIf cfg.enable {
      description = "Run server backup";

      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
      };
    };
  };
}
