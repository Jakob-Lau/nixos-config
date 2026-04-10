{ config, pkgs, lib, ... }:
{

  users.users.jakob = {
    isNormalUser = true;
    home = "/home/jakob";
    group = "jakob";
    extraGroups = [
      "adbusers" # adb control
      "audio" # sound control
      "dialout" # serial-console
      "docker" # usage of `docker` socket
      "input" # mouse control
      "libvirtd" # kvm control
      "networkmanager" # wireless configuration
      "podman" # usage of `podman` socket
      "video" # screen control
      "wheel" # `sudo` for the user.
    ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA1cVtRzblkjEJlT7e9aZaudVbVCqHk1O2sswAMAMKPi desktop-pc"
    ];
  };

  users.groups.jakob = {
    gid = 1000;
  };
}
