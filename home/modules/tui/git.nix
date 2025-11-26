{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ pass ];

  programs.git = {
    enable = true;
    settings = {
      user.email = "will.bradshaw50@gmail.com";
      user.name = "will";
      signing = {
        signByDefault = true;
        key = "${config.sops.secrets."sshkey/private".path}";
      };
      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      init.defaultBranch = "main";
      gpg.format = "ssh";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
