{
  config,
  pkgs,
  ...
}:
let
  contextName = "lima-docker";
  dockerSocket = "${config.home.homeDirectory}/.lima/docker/sock/docker.sock";
in
{
  home.packages = [
    pkgs.amazon-ecr-credential-helper
    pkgs.docker-client
  ];

  programs.docker-cli = {
    enable = true;
    configDir = ".docker";
    settings = {
      credsStore = "ecr-login";
      currentContext = contextName;
    };
    contexts.${contextName} = {
      Metadata.Description = "Rootful Docker Engine managed by Lima";
      Endpoints.docker.Host = "unix://${dockerSocket}";
    };
  };
}
