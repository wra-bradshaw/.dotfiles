{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.orbstack
    brewCasks.anki
    brewCasks.audacity
    brewCasks.vlc
    (pkgs.brewCasks.eloston-chromium.overrideAttrs (old: {
      nativeBuildInputs = old.nativeBuildInputs ++ [
        pkgs.darwin.xattr
      ];
      fixupPhase = ''
        xattr -cr $out/Applications/Chromium.app
      '';
    }))
  ];
}
