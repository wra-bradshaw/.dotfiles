{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.anki
    brewCasks.audacity
    brewCasks.vlc
    brewCasks.jan
    brewCasks.handy
    brewCasks.obsidian
    brewCasks.roblox
    brewCasks.gimp
    brewCasks.utm
    brewCasks.claude
    brewCasks.cursor
    brewCasks.qlab
    brewCasks.lookaway
    brewCasks.syntax-highlight
    brewCasks.sketch
    brewCasks.balenaetcher
    shortcat
  ];
}
