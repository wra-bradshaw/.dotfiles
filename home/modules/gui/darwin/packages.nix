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
    brewCasks.gimp
    brewCasks.hammerspoon
    brewCasks.utm
    brewCasks.claude
    raycast
    ice-bar
    shortcat
    autopip
  ];
}
