{ pkgs, ... }:
{
  services.socktainer.enable = true;
  environment.systemPackages = [
    pkgs.container
  ];
  environment.pathsToLink = [
    "/libexec"
  ];
}
