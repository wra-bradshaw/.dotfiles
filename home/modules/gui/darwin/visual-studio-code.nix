{ pkgs, ... }:
{
  home.packages = [
    (pkgs.brewCasks."visual-studio-code".overrideAttrs (old: {
      fixupPhase = ''
        mkdir -p "$out/bin"
        ln -s "$out/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "$out/bin/code"
      '';
    }))
  ];
}
