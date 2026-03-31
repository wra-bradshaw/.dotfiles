{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.omniwm;
in
{
  options.services.omniwm = with lib; {
    enable = mkEnableOption "OmniWM keyboard navigation / tiling window manager";

    package = mkPackageOption pkgs "omniwm" { };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = { };
      example = {
        "ipcEnabled" = true;
        "hotkeysEnabled" = true;
        "gapSize" = 10.0;
        "outerGapLeft" = 12.0;
        "outerGapRight" = 12.0;
        "outerGapTop" = 12.0;
        "outerGapBottom" = 12.0;
        "workspaceBar.enabled" = true;
        "workspaceBar.showLabels" = true;
        "quakeTerminal.enabled" = true;
      };
      description = ''
        UserDefaults keys for OmniWM domain `com.barut.OmniWM`.

        OmniWM stores runtime preferences in macOS UserDefaults under keys like
        `settings.*` (for example `settings.ipcEnabled`).

        Values are written declaratively via Home Manager's Darwin defaults support.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      (lib.hm.assertions.assertPlatform "services.omniwm" pkgs lib.platforms.darwin)
    ];

    home.packages = [ cfg.package ];
    targets.darwin.defaults."com.barut.OmniWM.settings" = cfg.settings;

    # Quit running OmniWM before launchd restart on switch.
    # We quit the app process itself because launchd tracks only `open -W -a ...`.
    home.activation.preOmniwmRestart = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
      if /usr/bin/pgrep -xq OmniWM 2>/dev/null || /usr/bin/pgrep -xq omniwm 2>/dev/null; then
        /usr/bin/osascript -e 'tell application "OmniWM" to quit' 2>/dev/null || true
        /usr/bin/osascript -e 'tell application "omniwm" to quit' 2>/dev/null || true
        sleep 1
        /usr/bin/pkill -x OmniWM 2>/dev/null || true
        /usr/bin/pkill -x omniwm 2>/dev/null || true
      fi
    '';

    launchd.agents.omniwm = {
      enable = true;
      config = {
        ProgramArguments = [
          "/usr/bin/open"
          "-W"
          "-a"
          "${cfg.package}/Applications/OmniWM.app"
          "--args"
          "launch"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Interactive";
        LimitLoadToSessionType = "Aqua";
        Nice = -10;
        ThrottleInterval = 10;
      };
    };
  };
}
