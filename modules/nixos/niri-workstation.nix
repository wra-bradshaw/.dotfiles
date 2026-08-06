{
  config,
  pkgs,
  ...
}:
{
  networking.networkmanager.enable = true;

  programs.niri.enable = true;
  services = {
    greetd = {
      enable = true;
      settings.initial_session = {
        command = "${config.programs.niri.package}/bin/niri-session";
        user = config.username;
      };
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.niri.package}/bin/niri-session";
        user = "greeter";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    gnome.gnome-keyring.enable = true;
  };
  systemd.user.services.niri.enableDefaultPath = false;

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    pam.services.swaylock = { };
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.niri."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
  };

  environment.systemPackages = with pkgs; [
    ghostty
    fuzzel
    waybar
    mako
    swayidle
    swaylock
    swaybg
    xwayland-satellite
    wl-clipboard
    grim
    slurp
    brightnessctl
    playerctl
    pavucontrol
    helium
  ];
}
