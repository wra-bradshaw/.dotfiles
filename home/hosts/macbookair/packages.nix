{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.affinity-photo
    brewCasks.affinity-designer
    brewCasks.affinity-publisher
  ];
}
