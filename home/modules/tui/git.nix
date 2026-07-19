{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ pass ];

  programs.git = {
    enable = true;
    ignores = [
      ".pi"
      ".pi-subagents"
    ];
    signing = {
      format = "ssh";
      signByDefault = true;
      key = "${config.sops.secrets."sshkey/private".path}";
    };
    settings = {
      user.email = "will.bradshaw50@gmail.com";
      user.name = "will";
      credential.helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
      init.defaultBranch = "main";
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
