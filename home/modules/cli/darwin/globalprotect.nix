{ pkgs, ... }:
let
  portal = "vpn.unimelb.edu.au";

  workVpn = pkgs.writeShellApplication {
    name = "work-vpn";
    text = ''
      set -o pipefail

      ${pkgs.gpauth}/bin/gpauth ${portal} --browser remote |
        /usr/bin/sudo ${pkgs.gpclient}/bin/gpclient connect ${portal} \
          --cookie-on-stdin
    '';
  };

  workVpnDisconnect = pkgs.writeShellApplication {
    name = "work-vpn-disconnect";
    text = ''
      /usr/bin/sudo ${pkgs.gpclient}/bin/gpclient disconnect
    '';
  };
in
{
  home.packages = [
    pkgs.gpclient
    pkgs.gpauth
    workVpn
    workVpnDisconnect
  ];
}
