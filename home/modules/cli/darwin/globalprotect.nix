{ pkgs, ... }:
let
  portal = "vpn.unimelb.edu.au";

  workVpn = pkgs.writeShellApplication {
    name = "work-vpn";
    text = ''
      usage() {
        cat <<'EOF'
      Usage: work-vpn [connect|disconnect]

      With no command, connect to the work VPN.
      Use "disconnect" to end the VPN session, or "help" to show this message.
      EOF
      }

      if [ "$#" -gt 1 ]; then
        echo "work-vpn: expected one command" >&2
        usage >&2
        exit 2
      fi

      command="''${1:-connect}"
      case "$command" in
        connect)
          cookieCache="$HOME/.config/gpclient/cookie.json"
          echo "Trying the saved VPN login; if needed, sign in at the URL below and paste the callback." >&2

          /usr/bin/sudo ${pkgs.gpclient}/bin/gpclient connect ${portal} \
            --browser remote \
            --cookie-cache "$cookieCache"
          ;;
        disconnect)
          /usr/bin/sudo ${pkgs.gpclient}/bin/gpclient disconnect
          ;;
        help|-h|--help)
          usage
          ;;
        *)
          echo "work-vpn: unknown command: $command" >&2
          usage >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = [ workVpn ];
}
