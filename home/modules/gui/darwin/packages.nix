{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rift
    opencode-desktop
    brewCasks.anki
    brewCasks.audacity
    brewCasks.vlc
    brewCasks.jan
    brewCasks.handy
    brewCasks.obsidian
    brewCasks.lookaway
    brewCasks.syntax-highlight
    brewCasks.codex-app
    brewCasks.intellij-idea
  ];
}
