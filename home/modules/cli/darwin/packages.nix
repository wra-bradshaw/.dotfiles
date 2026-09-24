{ pkgs, ... }:
{
  home.packages = with pkgs; [
    container
    apfel-llm
    codex
    ngrok
    openconnect
    snap
    ical
    claude-code
  ];
}
