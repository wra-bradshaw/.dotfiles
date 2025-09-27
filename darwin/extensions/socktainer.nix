{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.socktainer;
in
{
  options.services.socktainer = {
    enable = mkEnableOption "Socktainer, a Docker-compatible REST API on top of Apple container";

    package = mkPackageOption pkgs "socktainer" { };

    logFile = mkOption {
      type = types.path;
      default = "/var/tmp/socktainer.log";
      description = "Combined stdout and stderr of the socktainer process. Set to /dev/null to disable.";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      launchd.user.agents.socktainer = {
        serviceConfig = {
          KeepAlive = true;
          RunAtLoad = true;
          StandardErrorPath = cfg.logFile;
          StandardOutPath = cfg.logFile;
          ProgramArguments = [
            (getExe cfg.package)
          ];
        };
      };
    })
  ];
}
