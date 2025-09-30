{ config, ... }:
{
  programs.docker-cli.contexts = {
    apple-container = {
      Metadata = {
        Description = "Apple Native Containers via Socktainer";
      };
      Endpoints.docker = {
        Host = "unix://${config.home.homeDirectory}/.socktainer/container.sock";
        SkipTLSVerify = false;
      };
    };
  };
}
