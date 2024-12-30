{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    liberation_ttf
    libre-franklin
    libre-baskerville
    inter
    garamond-libre
    corefonts
  ];

}
