{ pkgs, ... }:
{
  home.packages = [ pkgs.amazon-ecr-credential-helper ];

  # nerdctl reads Docker-compatible credential-helper configuration.
  xdg.configFile."containers/nerdctl/nerdctl.toml".text = ''
    namespace = "default"
  '';
  home.file.".docker/config.json".text = builtins.toJSON {
    credsStore = "ecr-login";
  };
}
