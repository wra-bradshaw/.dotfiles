{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.orbstack
    brewCasks.anki
    brewCasks.audacity
    brewCasks.vlc
    brewCasks.obsidian
    brewCasks.calibre
    brewCasks.roblox
    raycast
    shortcat
    autopip
  ];
}
