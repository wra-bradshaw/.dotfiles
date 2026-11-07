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

  # Runs as root inside the Nix daemon after every successful build. It must not
  # fail (a non-zero exit fails the build) and shouldn't block the build, so the
  # upload is detached and its output goes to a log.
  postBuildHook = pkgs.writeShellScript "cf-nix-cache-post-build-hook" ''
    [ -n "$OUT_PATHS" ] || exit 0
    export HOME=${lib.escapeShellArg userHome}
    export XDG_CONFIG_HOME="$HOME/.config"
    (
      ${lib.getExe pkgs.cf-nix-cache} push will $OUT_PATHS
    ) >>/var/log/cf-nix-cache-push.log 2>&1 </dev/null &
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

  system.activationScripts.postActivation.text = lib.mkAfter ''
    netrc_source=${lib.escapeShellArg netrcSource}
    if [ -s "$netrc_source" ] && ! /usr/bin/awk '{print $NF}' "$netrc_source" | /usr/bin/grep -qFf /dev/stdin /nix/var/determinate/netrc; then
      echo "restarting the Nix daemon to load the cf-nix-cache pull token"
      /bin/launchctl kickstart -k system/systems.determinate.nix-daemon \
        || echo "warning: could not restart the Nix daemon; the cf-nix-cache substituter is not active yet" >&2
    fi
  '';
}
