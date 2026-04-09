{ config, pkgs, lib, ... }:
{
  # Packages
  environment.systemPackages = with pkgs; [
    bandwhich
    #bind # dig  # is a DNS Server
    #borgbackup  # maybe relevant for backups
    #cryptsetup  # disk encryption
    file
    fzf          # command-line fuzzy finder
    git
    # gitAndTools.delta    # don't know what this is
    # gnufdisk
    gptfdisk  # partitioning tool
    # htop    # interactive process viewer (task manager)
    jq
    # killall   # no homepage
    lsof   # tool to list open files
    mosh   # mobile shell, alternative for ssh with intermittent connectivity
    # multipath-tools # kpartx # Tools for the linux multipathing storage driver
    mtr   # network diagnostic
    nmap  # network discovery
    # nmon  # performance monitoring tool
    ouch # de-/compress
    # pciutils
    # progress # monitor basic commands (cp, mv, tar)
    # pv # monitor progress of data through a pipeline (shell pipe)
    reptyr  # re ptying programs. Attach a long running program/process to a new terminal
    rsync
    # screen # window manager
    stress-ng # stress test
    usbutils  # tools for working with USB devices
    tmux      # terminal multiplexer
    vim
    wget
    whois
    zip
    unzip
  ];

  time.timeZone = "Europe/Berlin";
  services.timesyncd.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "de";
    xkb.variant = "";
  };


  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "de";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # location service
  location.provider = "geoclue2";

}

