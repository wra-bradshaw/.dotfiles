{ config, lib, ... }:
let
  configDir = "/Users/${config.username}/.config/cf-nix-cache";
  netrcSource = "${configDir}/netrc";
in
{
  environment.etc."nix/nix.custom.conf".text = ''
    !include ${configDir}/nix.conf
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
