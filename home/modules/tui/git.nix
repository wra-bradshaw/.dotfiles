{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ pass ];

  programs.git = {
    enable = true;
    userEmail = "will.bradshaw50@gmail.com";
    userName = "will";
    signing = {
      signByDefault = true;
      key = "${config.sops.secrets."sshkey/private".path}";
    };
    delta = {
      enable = true;

    };
    extraConfig = {
      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };
}
