{ pkgs, ... }:
{
  home.packages = [ pkgs.amazon-ecr-credential-helper ];

  programs.docker-cli = {
    enable = true;
    settings = {
      currentContext = pkgs.lib.mkDefault "default";
      credsStore = "ecr-login";
    };
  };
}
