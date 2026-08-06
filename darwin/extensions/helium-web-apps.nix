{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.helium;
  webApps = lib.filterAttrs (_: app: app.enable) cfg.webApps;
  policy = {
    WebAppInstallForceList = lib.mapAttrsToList (_: app: {
      inherit (app) url;
      default_launch_container = app.defaultLaunchContainer;
      install_as_shortcut = app.installAsShortcut;
    }) webApps;
  };
  policyFile = pkgs.writeText "helium-managed-policy.plist" (
    lib.generators.toPlist { escape = true; } policy
  );
  diagnostic = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: app: ''
      found=""
      while IFS= read -r candidate; do
        plist="$candidate/Contents/Info.plist"
        [ -f "$plist" ] || continue
        shortcut_url=$(/usr/libexec/PlistBuddy -c 'Print :CrAppModeShortcutURL' "$plist" 2>/dev/null || true)
        if [ "$shortcut_url" = ${lib.escapeShellArg app.url} ]; then
          found="$candidate"
          break
        fi
      done < <(/usr/bin/mdfind 'kMDItemContentType == "com.apple.application-bundle"' 2>/dev/null || true)

      if [ -z "$found" ]; then
        echo "warning: Helium web app '${name}' was not found for shortcut URL ${app.url}" >&2
      else
        actual_bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$found/Contents/Info.plist" 2>/dev/null || true)
        shortcut_id=$(/usr/libexec/PlistBuddy -c 'Print :CrAppModeShortcutID' "$found/Contents/Info.plist" 2>/dev/null || true)
        if [ "$actual_bundle_id" != ${lib.escapeShellArg app.expectedBundleId} ]; then
          echo "warning: Helium web app '${name}' at '$found' has bundle ID '$actual_bundle_id' (Chromium app ID '$shortcut_id'); expected '${app.expectedBundleId}'" >&2
        fi
      fi
    '') webApps
  );
in
{
  options.programs.helium.webApps = lib.mkOption {
    default = { };
    description = "Web apps force-installed by Helium policy.";
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          enable = lib.mkEnableOption "this Helium web app" // {
            default = true;
          };
          url = lib.mkOption {
            type = lib.types.str;
            description = "The exact install/shortcut URL for the web app.";
          };
          expectedBundleId = lib.mkOption {
            type = lib.types.str;
            description = "Pinned bundle ID expected from Helium's generated app.";
          };
          defaultLaunchContainer = lib.mkOption {
            type = lib.types.enum [
              "tab"
              "window"
            ];
            default = "window";
            description = "Whether Helium launches the app in a tab or standalone window.";
          };
          installAsShortcut = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to install the URL as a shortcut instead of a PWA.";
          };
        };
      }
    );
  };

  config = lib.mkIf (webApps != { }) {
    # This fragment runs before nix-darwin's defaults phase.
    system.activationScripts.etc.text = lib.mkAfter ''
      mkdir -p "/Library/Managed Preferences"
      install -m 0644 ${policyFile} "/Library/Managed Preferences/net.imput.helium.plist"
    '';

    system.activationScripts.postActivation.text = lib.mkAfter diagnostic;
  };
}
