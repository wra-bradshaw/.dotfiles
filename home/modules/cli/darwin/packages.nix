{ pkgs, ... }:
{
  home.packages = with pkgs; [
    container
    apfel-llm
    codex
    ngrok
    snap
  ];
}
