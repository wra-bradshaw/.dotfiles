{
  config,
  lib,
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
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    pkgs.docker-credential-helpers
  ];

  programs.docker-cli = {
    enable = true;
    configDir = ".docker";
    settings = {
      currentContext = contextName;
      credHelpers = {
        "301436506805.dkr.ecr.ap-southeast-2.amazonaws.com" = "ecr-login";
        "public.ecr.aws" = "ecr-login";
      };
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      credsStore = "osxkeychain";
    };
    contexts.${contextName} = {
      Metadata.Description = "Rootful Docker Engine managed by Lima";
      Endpoints.docker.Host = "unix://${dockerSocket}";
    };
  };
}
