{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.affinity
  ];
}
