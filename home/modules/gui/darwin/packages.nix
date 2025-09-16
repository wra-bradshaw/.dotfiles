{ pkgs, ... }:
{
  home.packages = with pkgs; [
    brewCasks.anki
    brewCasks.audacity
    brewCasks.vlc
    brewCasks.obsidian
    brewCasks.calibre
    brewCasks.roblox
    (brewCasks.messenger.overrideAttrs (oldAttrs: {
      src = pkgs.fetchurl {
        url = builtins.head oldAttrs.src.urls;
        hash = "sha256-7VRhDt4ZThAp4oS8EfO5QQs5LAyt564rirtjwby3Ft8=";
      };
    }))
    brewCasks.gimp
    brewCasks.utm
    brewCasks.claude
    brewCasks.cursor
    brewCasks.qlab
    brewCasks.lookaway
    brewCasks.syntax-highlight
    (brewCasks.vivaldi.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.gnutar ];
      unpackPhase = "tar -xvJf $src";
    }))
    raycast
    shortcat
    autopip
  ];
}
