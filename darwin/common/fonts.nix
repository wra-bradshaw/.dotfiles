{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    eb-garamond
    libertinus
  ];
}
