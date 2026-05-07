{ pkgs, ... }:
{
  home.packages = with pkgs; [
    container
    apfel-llm
  ];
}
