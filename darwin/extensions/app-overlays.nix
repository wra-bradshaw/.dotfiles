{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.appOverlays;
  enabledApps = filterAttrs (_: app: app.enable) cfg.apps;

  overlayHelper = pkgs.stdenv.mkDerivation {
    pname = "toggle-overlay-app";
    version = "0.1.0";

    src = ./toggle-overlay-app.m;

    dontUnpack = true;
    buildPhase = ''
      $CC -fobjc-arc -framework Cocoa -framework ApplicationServices "$src" -o toggle-overlay-app
    '';
    installPhase = ''
      mkdir -p $out/bin
      install -m755 toggle-overlay-app $out/bin/toggle-overlay-app
    '';

    meta.mainProgram = "toggle-overlay-app";
  };

  hotkeyConfig = concatStringsSep "\n" (
    mapAttrsToList (
      _: app:
      optionalString (app.hotkey != null) "${app.hotkey} : ${getExe overlayHelper} ${app.bundleId}"
    ) enabledApps
  );
in
{
  options.services.appOverlays = {
    enable = mkEnableOption "floating app overlays";

    apps = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkOption {
              type = types.bool;
              default = true;
              description = "Whether to generate a hotkey for this app overlay.";
            };

            bundleId = mkOption {
              type = types.str;
              description = "macOS bundle identifier for the app overlay.";
            };

            hotkey = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "skhd key binding that toggles this app overlay.";
            };
          };
        }
      );
      default = { };
      description = "Apps that should behave as independently toggled floating overlays.";
    };
  };

  config = mkIf cfg.enable {
    services.skhd = {
      enable = true;
      skhdConfig = mkAfter ''
        ${hotkeyConfig}
      '';
    };
  };
}
