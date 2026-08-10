{
  lib,
  pkgs,
  ...
}:
let
  signingKeyCommand = pkgs.writeShellScript "git-rbw-signing-key" ''
    set -eu
    public_key="$(${lib.getExe pkgs.rbw} get --field public_key "Primary SSH Key")"
    printf 'key::%s\n' "$public_key"
  '';
in
{
  home.packages = [ pkgs.pass ];

  programs.git = {
    enable = true;
    ignores = [
      ".pi"
      ".pi-subagents"
    ];
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      user.email = "will.bradshaw50@gmail.com";
      user.name = "will";
      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      init.defaultBranch = "main";
      gpg.ssh.defaultKeyCommand = "${signingKeyCommand}";
      url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
