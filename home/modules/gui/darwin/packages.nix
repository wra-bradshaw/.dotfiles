{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rift
    brewCasks.anki
    brewCasks.audacity
    brewCasks.jan
    brewCasks.lookaway
    brewCasks.syntax-highlight
    brewCasks.firefox
    brewCasks.codex-app
    brewCasks.intellij-idea
    brewCasks.sketch
  ];
}
