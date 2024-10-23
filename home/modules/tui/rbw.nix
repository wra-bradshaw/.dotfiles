{ pkgs, config, ... }:
let
  rbwLoginScript = pkgs.writeShellScript "rbw-login" ''
    export CLIENT_ID=$(< ${config.sops.secrets."bitwarden/client_id".path})
    export CLIENT_SECRET=$(< ${config.sops.secrets."bitwarden/client_secret".path})

    ${pkgs.expect}/bin/expect -c "spawn ${pkgs.lib.getExe pkgs.rbw} register
    expect \"API key client__id: \"
    send \"$::env(CLIENT_ID)\\n\"
    expect \"API key client__secret: \"
    send \"$::env(CLIENT_SECRET)\\n\""

    unset CLIENT_ID
    unset CLIENT_SECRET
  '';
in
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "will@ionata.com.au";
      pinentry = pkgs.pinentry-tty;
    };
  };

  launchd.agents.rbw-auth =
    if pkgs.stdenv.hostPlatform.isDarwin then
      {
        enable = true;
        config = {
          KeepAlive = false;
          RunAtLoad = true;
          StandardErrorPath = "/tmp/rbw_error";
          StandardOutPath = "/tmp/rbw_out";
          Program = "${rbwLoginScript}";
        };
      }
    else
      null;

  systemd.user.services.rbw-auth =
    if pkgs.stdenv.hostPlatform.isLinux then
      {
        Unit = {
          Description = "Authenticate with Bitwarden for rbw cli";
          After = [ "sops-nix.service" ];
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          ExecStart = rbwLoginScript;
        };
      }
    else
      null;
}
