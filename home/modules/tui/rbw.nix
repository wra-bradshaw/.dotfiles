{
  lib,
  pkgs,
  ...
}:
let
  rbwSshSocket =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "\${TMPDIR%/}/rbw-$(id -u)/ssh-agent-socket"
    else
      "\${XDG_RUNTIME_DIR}/rbw/ssh-agent-socket";
in
{
  programs.rbw = {
    enable = true;
    settings = {
      email = "will.bradshaw50@gmail.com";
      lock_timeout = 3600;
      sync_interval = 3600;
      pinentry = pkgs.pinentry-tty;
    };
  };

  programs.zsh.envExtra = ''
    export SSH_AUTH_SOCK="${rbwSshSocket}"
  '';

  home.activation.rbwSshAgentSocket = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      /bin/launchctl setenv SSH_AUTH_SOCK "${rbwSshSocket}"
    ''
  );
}
