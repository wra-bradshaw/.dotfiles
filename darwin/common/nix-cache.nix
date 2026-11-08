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

  # Finished builds are queued here, and one drainer at a time pushes the whole
  # queue with a single `cf-nix-cache push`. A push per build would upload the
  # shared parts of overlapping closures many times over, and run many pushes
  # at once.
  spoolDir = "/var/lib/cf-nix-cache";
  # /var/run is emptied at boot, so a drainer killed by a restart cannot leave
  # the lock behind.
  lockDir = "/var/run/cf-nix-cache-push.lock";

  # The CLI runs nix and nix-store from PATH, which the daemon's environment
  # doesn't provide.
  drainQueue = pkgs.writeShellScript "cf-nix-cache-drain" ''
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
    export HOME=${lib.escapeShellArg userHome}
    export XDG_CONFIG_HOME="$HOME/.config"
    spool=${lib.escapeShellArg spoolDir}
    lock=${lib.escapeShellArg lockDir}

    # macOS has no flock, but mkdir is atomic.
    take_lock() {
      if mkdir "$lock" 2>/dev/null; then
        echo "$$" >"$lock/pid"
        return 0
      fi
      # A drainer that died without releasing the lock.
      holder="$(cat "$lock/pid" 2>/dev/null || true)"
      if [ -n "$holder" ] && ! kill -0 "$holder" 2>/dev/null; then
        rm -rf "$lock"
        mkdir "$lock" 2>/dev/null && echo "$$" >"$lock/pid" && return 0
      fi
      return 1
    }

    while take_lock; do
      while [ -s "$spool/queue" ]; do
        # Builds that finish from here on append to a new queue.
        mv "$spool/queue" "$spool/batch"
        # Let a hook that opened the queue before the move finish its write.
        sleep 1
        paths="$(tr ' ' '\n' <"$spool/batch" | sort -u | while read -r path; do
          if [ -n "$path" ] && [ -e "$path" ]; then echo "$path"; fi
        done)"
        if [ -n "$paths" ]; then
          echo "$(date '+%Y-%m-%dT%H:%M:%S') pushing $(echo "$paths" | wc -l | tr -d ' ') built paths"
          # shellcheck disable=SC2086 # one argument per path
          ${lib.getExe' pkgs.cf-nix-cache "cf-nix-cache"} push will $paths ||
            echo "push failed; the next build pushes these paths' closures again"
        fi
        rm -f "$spool/batch"
      done
      rm -rf "$lock"
      # A build queued after the last check and before the lock was released
      # found the lock taken and left its paths to this drainer.
      [ -s "$spool/queue" ] || break
    done
  '';

  # Runs as root inside the Nix daemon after every successful build. It must not
  # fail (a non-zero exit stops further builds) and shouldn't block the build, so
  # it only queues the paths and starts a detached drainer.
  postBuildHook = pkgs.writeShellScript "cf-nix-cache-post-build-hook" ''
    [ -n "$OUT_PATHS" ] || exit 0
    mkdir -p ${lib.escapeShellArg spoolDir}
    # One short line per build, so concurrent appends do not interleave.
    echo "$OUT_PATHS" >>${lib.escapeShellArg "${spoolDir}/queue"}
    ${drainQueue} >>/var/log/cf-nix-cache-push.log 2>&1 </dev/null &
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
