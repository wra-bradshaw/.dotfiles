{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.anki
    brewCasks.audacity
    brewCasks.vlc
    brewCasks.obsidian
    brewCasks.calibre
    brewCasks.roblox
    brewCasks.gimp
    brewCasks.hammerspoon
    brewCasks.utm
    brewCasks.claude
    brewCasks.cursor
    brewCasks.qlab
    raycast
    shortcat
    autopip
  ];
}
