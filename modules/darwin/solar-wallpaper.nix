{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.solarWallpaper;
  helper = pkgs.writeShellScript "solar-wallpaper-reconcile" (builtins.readFile ./solar-wallpaper.sh);
  sourceCatalog = "/System/Library/ExtensionKit/Extensions/WallpaperAerialsExtension.appex/Contents/Resources/entries.json";
  preferencesDomain = "com.apple.wallpaper.aerial";
in
{
  options.services.solarWallpaper.enable = lib.mkEnableOption "Automatic Tahoe and Golden Gate wallpapers";

  config.system.activationScripts.postActivation.text = lib.mkAfter ''
    solar_wallpaper_force_restart=0
    if /usr/bin/defaults read /Library/Preferences/FeatureFlags/Domain/Wallpaper TahoeCombined >/dev/null 2>&1; then
      if /usr/bin/defaults delete /Library/Preferences/FeatureFlags/Domain/Wallpaper TahoeCombined; then
        solar_wallpaper_force_restart=1
      else
        echo "warning: solarWallpaper could not remove the obsolete TahoeCombined feature flag" >&2
      fi
    fi

    solar_wallpaper_uid=$(/usr/bin/id -u ${lib.escapeShellArg config.username})
    solar_wallpaper_command=(
      ${helper}
      ${if cfg.enable then "enable" else "disable"}
      ${lib.escapeShellArg config.userHome}
      ${lib.escapeShellArg sourceCatalog}
      ${lib.escapeShellArg preferencesDomain}
      ${lib.getExe pkgs.jq}
      "$solar_wallpaper_force_restart"
      1
    )

    if /bin/launchctl print "gui/$solar_wallpaper_uid" >/dev/null 2>&1; then
      if ! /bin/launchctl asuser "$solar_wallpaper_uid" \
        /usr/bin/sudo -u ${lib.escapeShellArg config.username} -- \
        /usr/bin/env HOME=${lib.escapeShellArg config.userHome} "''${solar_wallpaper_command[@]}"; then
        echo "warning: solarWallpaper reconciliation failed; nix-darwin activation will continue" >&2
      fi
    else
      echo "warning: solarWallpaper could not find the GUI session for ${config.username}; running reconciliation outside the GUI bootstrap context" >&2
      if ! /usr/bin/sudo -u ${lib.escapeShellArg config.username} -- \
        /usr/bin/env HOME=${lib.escapeShellArg config.userHome} "''${solar_wallpaper_command[@]}"; then
        echo "warning: solarWallpaper reconciliation failed; nix-darwin activation will continue" >&2
      fi
    fi
  '';
}
