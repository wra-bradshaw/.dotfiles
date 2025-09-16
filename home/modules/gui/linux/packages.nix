{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mixxx
    gimp
    ydotool
    calibre
    obs-studio
    audacity
    inkscape
    xorg.xwininfo
    fontforge-gtk
    # zotero
    mpv
    lunar-client
  ];

  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
  services.flatpak.uninstallUnmanagedPackages = true;
}
