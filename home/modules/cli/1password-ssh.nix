{
  config,
  lib,
  pkgs,
  ...
}:
let
  portableSocket = "${config.home.homeDirectory}/.1password/agent.sock";
  macSocket = "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  programs.zsh.envExtra = ''
    export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
  '';

  programs.ssh.settings."*".IdentityAgent = "~/.1password/agent.sock";

  home.activation.onePasswordSshSymlink = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.1password"
      ln -sf "${macSocket}" "$HOME/.1password/agent.sock"
      /bin/launchctl setenv SSH_AUTH_SOCK "${portableSocket}"
    ''
  );
}
