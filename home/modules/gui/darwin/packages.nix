{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rift
    opencode-desktop
    brewCasks.anki
    brewCasks.audacity
    brewCasks.jan
    brewCasks.lookaway
    brewCasks.syntax-highlight
    brewCasks.codex-app
    brewCasks.intellij-idea
  ];
}
