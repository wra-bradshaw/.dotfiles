{ pkgs, ... }:
{
  home.packages = [ pkgs.amazon-ecr-credential-helper ];

  programs.docker-cli = {
    enable = true;
    settings = {
      currentContext = "default";
      credsStore = "ecr-login";
    };
  };
}
