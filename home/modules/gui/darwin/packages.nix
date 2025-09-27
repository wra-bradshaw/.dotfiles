{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.anki
    brewCasks.audacity
    brewCasks.vlc
    brewCasks.obsidian
    brewCasks.calibre
    brewCasks.roblox
    brewCasks.messenger
    brewCasks.podman-desktop
    brewCasks.gimp
    brewCasks.utm
    brewCasks.claude
    brewCasks.cursor
    brewCasks.qlab
    brewCasks.lookaway
    brewCasks.syntax-highlight
    raycast
    shortcat
    autopip
  ];
}
