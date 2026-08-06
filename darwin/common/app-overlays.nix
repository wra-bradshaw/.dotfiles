{ config, ... }:
let
  heliumApps = config.programs.helium.webApps;
in
{
  services.appOverlays = {
    enable = true;
    apps = {
      music = {
        bundleId = "com.apple.Music";
        hotkey = "alt - m";
      };
      gmail = {
        bundleId = heliumApps.gmail.expectedBundleId;
        hotkey = "alt - g";
      };
      outlook = {
        bundleId = heliumApps.outlook.expectedBundleId;
        hotkey = "alt - o";
      };
      calendar = {
        bundleId = "com.apple.iCal";
        hotkey = "alt - c";
      };
    };
  };
}
