{
  lib,
  pkgs,
  ...
}:
let
  opSshSign =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    else
      lib.getExe' pkgs._1password-gui "op-ssh-sign";
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
      user = {
        email = "will.bradshaw50@gmail.com";
        name = "will";
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDR/R+t7y0cUpkC31jOylQ12qnRIOZmbBDu/ZVFW7Dgm";
      };
      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      init.defaultBranch = "main";
      gpg.ssh.program = opSshSign;
      url."ssh://git@github.com/".pushInsteadOf = "https://github.com/";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
