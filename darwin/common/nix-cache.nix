{
  config,
  lib,
  pkgs,
  ...
}:
let
  userHome = "/Users/${config.username}";
  configDir = "${userHome}/.config/cf-nix-cache";
  netrcSource = "${configDir}/netrc";

  spoolDir = "/var/lib/cf-nix-cache";

  postBuildHook = pkgs.writeShellScript "cf-nix-cache-post-build-hook" ''
    [ -n "$OUT_PATHS" ] || exit 0
    mkdir -p ${lib.escapeShellArg spoolDir}
    echo "$OUT_PATHS" >>${lib.escapeShellArg "${spoolDir}/queue"}
    exit 0
  '';
in
{
  environment.etc."nix/nix.custom.conf".text = ''
    !include ${configDir}/nix.conf
    post-build-hook = ${postBuildHook}
  '';

  environment.etc."determinate/config.json".text = builtins.toJSON {
    authentication.additionalNetrcSources = [ netrcSource ];
  };

  launchd.daemons.cf-nix-cache-watch.serviceConfig = {
    ProgramArguments = [
      (lib.getExe' pkgs.cf-nix-cache "cf-nix-cache")
      "watch"
      "run"
      "will"
      "--spool"
      spoolDir
    ];
    EnvironmentVariables = {
      HOME = userHome;
      XDG_CONFIG_HOME = "${userHome}/.config";
      PATH = "/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin";
    };
    RunAtLoad = true;
    KeepAlive = true;
    ProcessType = "Background";
    StandardOutPath = "/var/log/cf-nix-cache-watch.log";
    StandardErrorPath = "/var/log/cf-nix-cache-watch.log";
  };

  system.activationScripts.postActivation.text = lib.mkAfter ''
    netrc_source=${lib.escapeShellArg netrcSource}
    if [ -s "$netrc_source" ] && ! /usr/bin/awk '{print $NF}' "$netrc_source" | /usr/bin/grep -qFf /dev/stdin /nix/var/determinate/netrc; then
      echo "restarting the Nix daemon to load the cf-nix-cache pull token"
      /bin/launchctl kickstart -k system/systems.determinate.nix-daemon \
        || echo "warning: could not restart the Nix daemon; the cf-nix-cache substituter is not active yet" >&2
    fi
  '';
}
