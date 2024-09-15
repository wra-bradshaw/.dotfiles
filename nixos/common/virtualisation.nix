{ config, ... }:
{
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  users.users.${config.username}.extraGroups = [
    "libvirtd"
    "docker"
  ];
}
